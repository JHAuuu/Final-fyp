using System;
using fyp.Authentication;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.Services;
using System.Data;
using Microsoft.AspNet.SignalR;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using ZXing;

namespace fyp
{
    public partial class UsersManagement : AdminPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            var master = this.Master as DashMasterPage;
            if (master != null)
            {
                master.titleText = "User Management";
            }

            if (!IsPostBack)
            {
                // Check if there's a success message in the session
                if (Session["SuccessMessage"] != null)
                {
                    MessageBox.Text = Session["SuccessMessage"].ToString();
                    Session.Remove("SuccessMessage"); // Clear the message after showing it
                }
                // Initialize the filter
                ViewState["SelectedFilter"] = ddlFilter.SelectedValue; // Store the initial filter value
                BindGrid(); // Bind the GridView initially
            }
        }

        [WebMethod]
        public static string GetUserData(string UserId)
        {
            string htmlResponse = "";

            // SQL query to fetch user details by UserId  
            string query = @"  
        SELECT   
            u.UserName,  
            b.BookTitle,  
            bc.BookCopyId,  
            l.LoanId,  
            l.StartDate,  
            l.EndDate,  
            l.Status,  
            pu.TotalFine  
        FROM   
            [User] u  
        INNER JOIN   
            Patron p ON u.UserId = p.UserId  
        INNER JOIN   
            Loan l ON p.PatronId = l.PatronId  
        INNER JOIN   
            BookCopy bc ON l.BookCopyId = bc.BookCopyId  
        INNER JOIN   
            Book b ON bc.BookId = b.BookId  
        LEFT JOIN   
            Punishment pu ON l.LoanId = pu.LoanId  
        WHERE   
            u.UserId = @UserId  
            AND l.Status IN('returning', 'preloaning')";

            // Parameters for the query  
            string[] arr = new string[2];
            arr[0] = "@UserId";
            arr[1] = UserId;

            // Execute the query  
            DataTable resultTable = DBHelper.ExecuteQuery(query, arr);

            // Check if any records were returned  
            if (resultTable.Rows.Count > 0)
            {
                // Loop through each row in the result table and construct the table rows dynamically  
                foreach (DataRow row in resultTable.Rows)
                {
                    string bookTitle = row["BookTitle"].ToString();
                    DateTime startDate = Convert.ToDateTime(row["StartDate"]);
                    DateTime endDate = Convert.ToDateTime(row["EndDate"]);
                    string loanStatus = row["Status"].ToString();
                    string totalFine = row["TotalFine"] != DBNull.Value ? "RM" + row["TotalFine"].ToString() : "RM0";
                    int loanId = Convert.ToInt32(row["LoanId"]);

                    // Calculate loan day difference  
                    int loanDay = (endDate - startDate).Days;

                    // Set the button text based on loanStatus  
                    string buttonText = loanStatus == "returning" ? "Return" : "Request Loan Book";
                    string buttonClickHandler = loanStatus == "returning"
                        ? $"updateLoanStatus({loanId}, 'returned')"
                        : $"updateLoanStatus({loanId}, 'loaning')";

                    // Construct each row of the table with the loan data  
                    htmlResponse += $@"  
                    <tr>  
                        <td>{bookTitle}</td>  
                        <td>{startDate:yyyy-MM-dd}</td>  
                        <td>{loanDay} days</td>  
                        <td>{totalFine}</td>  
                        <td>{loanStatus}</td>  
                        <td><button class='button' onclick=""{buttonClickHandler}; return false;"">{buttonText}</button></td>  
                    </tr>";
                }
            }
            else
            {
                htmlResponse = "<tr><td colspan='6'>No loan data available.</td></tr>";
            }

            // Log the final HTML response to check if data is being returned  
            Console.WriteLine(htmlResponse);  // Or use your preferred logging method  

            return htmlResponse;
        }

        [WebMethod]
        public static object UpdateLoanStatus(int loanId, string newStatus)
        {
            try
            {
                string query = @"
            UPDATE Loan
            SET Status = @Status
            WHERE LoanId = @LoanId";

                object[] arr = new object[4];
                arr[0] = "@Status";  // Corrected parameter name to match the SQL query
                arr[1] = newStatus;
                arr[2] = "@LoanId";  // Corrected parameter name to match the SQL query
                arr[3] = loanId;

                // Execute the query
                int rowsAffected = DBHelper.ExecuteNonQuery(query, arr);

                // Check if any rows were affected (should be 1 for a successful update)  
                bool updateSuccessful = rowsAffected == 1;

                return new { success = updateSuccessful };
            }
            catch (Exception ex)
            {
                return new { success = false, errorMessage = ex.Message };
            }

        }

        protected void btnSubmitUser_Click(object sender, EventArgs e)
        {
            try
            {
                string userName = txtUserName.Text.Trim();
                string userAddress = txtAddress.Text.Trim();
                string userEmail = txtEmail.Text.Trim();
                string userPhoneNumber = txtPhone.Text.Trim();
                string userPassword = txtUserPassword.Text.Trim();
                string educationLevel = ddlEducationLevel.Visible ? ddlEducationLevel.SelectedValue : null;

                // Check if the username or email already exists
                string checkQuery = "SELECT UserName, UserEmail FROM [User] WHERE UserName = @UserName OR UserEmail = @UserEmail";
                string[] checkParams = { "@UserName", userName, "@UserEmail", userEmail };

                DataTable resultTable = DBHelper.ExecuteQuery(checkQuery, checkParams);

                if (resultTable.Rows.Count > 0)
                {
                    bool usernameExists = false;
                    bool emailExists = false;

                    foreach (DataRow row in resultTable.Rows)
                    {
                        if (row["UserName"].ToString() == userName)
                            usernameExists = true;
                        if (row["UserEmail"].ToString() == userEmail)
                            emailExists = true;
                    }

                    string errorMessage = usernameExists && emailExists
                        ? "Both the username and email already exist. Please enter different values."
                        : usernameExists
                        ? "The username already exists. Please enter a different one."
                        : "The email already exists. Please enter a different one.";

                    ScriptManager.RegisterStartupScript(this, this.GetType(), "showalert", $"alert('{errorMessage}');", true);
                    return;
                }

                // Hash the password
                string hashPass = encryption.HashPassword(userPassword);

                // Determine user role based on email domain
                string UserRole = userEmail.EndsWith("@student.tarc.edu.my") ? "Student" :
                                  userEmail.EndsWith("@tarc.edu.my") ? "Teacher" : null;

                int initialTrustScore = UserRole == "Student" ? 100 : 120;
                string initialTrustLvl = UserRole == "Student" ? "High" : "Very High";

                // Insert new user into the [User] table
                string insertUserQuery = "INSERT INTO [User] (UserName, UserEmail, UserPhoneNumber, UserAddress, UserPassword, UserRole) " +
                                         "VALUES (@UserName, @UserEmail, @UserPhoneNumber, @UserAddress, @UserPassword, @UserRole); " +
                                         "SELECT SCOPE_IDENTITY();";

                string[] arrInsertUser = new string[12]
                {
            "@UserName", userName,
            "@UserEmail", userEmail,
            "@UserPhoneNumber", userPhoneNumber,
            "@UserAddress", userAddress,
            "@UserPassword", hashPass,
            "@UserRole", UserRole
                };

                object userResult = DBHelper.ExecuteScalar(insertUserQuery, arrInsertUser);

                if (userResult != null)
                {
                    int userId = Convert.ToInt32(userResult);

                    // Insert into Patron table
                    string insertPatronQuery = "INSERT INTO Patron (EduLvl, UserId) VALUES (@EduLvl, @UserId); SELECT SCOPE_IDENTITY();";

                    object eduLevelParam = UserRole == "Student" ? (object)educationLevel : DBNull.Value;

                    object[] arrInsertPatron = new object[4]
                    {
                "@EduLvl", eduLevelParam,
                "@UserId", userId
                    };

                    object patronResult = DBHelper.ExecuteScalar(insertPatronQuery, arrInsertPatron);

                    if (patronResult != null)
                    {
                        int patronId = Convert.ToInt32(patronResult);

                        // Insert into Trustworthy table
                        string insertTrustQuery = "INSERT INTO Trustworthy (TrustScore, TrustLvl, PatronId) VALUES (@TrustScore, @TrustLvl, @PatronId)";
                        string[] arrInsertTrust = new string[6]
                        {
                    "@TrustScore", initialTrustScore.ToString(),
                    "@TrustLvl", initialTrustLvl,
                    "@PatronId", patronId.ToString()
                        };

                        int trustRowsAffected = DBHelper.ExecuteNonQuery(insertTrustQuery, arrInsertTrust);

                        if (trustRowsAffected > 0)
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "showalert", "alert('Registration successful!');", true);
                        }
                        else
                        {
                            throw new Exception("Error while saving trust level data.");
                        }
                    }
                    else
                    {
                        throw new Exception("Error while registering Patron data.");
                    }
                }
                else
                {
                    throw new Exception("Error while registering user.");
                }
            }
            catch (Exception ex)
            {
                string errorMessage = "An unexpected error occurred: " + ex.Message;
                ScriptManager.RegisterStartupScript(this, this.GetType(), "showalert", $"alert('{errorMessage}');", true);
            }
        }


        private void BindGrid()
        {
            // Get the selected filter value from ViewState
            string selectedValue = ViewState["SelectedFilter"] as string;

            // Define the base SQL query for users with UserRole = 'User'
            string baseQuery = @"
                SELECT DISTINCT 
                    CAST([User].UserId AS INT) AS UserId, 
                    [User].UserName, 
                    [User].UserAddress, 
                    [User].UserEmail, 
                    [User].UserPhoneNumber 
                FROM [User]
                INNER JOIN Patron ON [User].UserId = Patron.UserId
                INNER JOIN Trustworthy ON Patron.PatronId = Trustworthy.PatronId
                WHERE [UserRole] IN ('Student', 'Teacher') 
                  AND [IsDeleted] = 0";

            try
            {
                // Modify query based on selected filter
                if (selectedValue == "Loan")
                {
                    SqlDataSource1.SelectCommand = baseQuery + @"
                AND [User].UserId IN (
                    SELECT DISTINCT CAST(U.UserId AS INT) 
                    FROM [User] AS U
                    INNER JOIN Patron AS P ON U.UserId = P.UserId
                    INNER JOIN Loan AS L ON P.PatronId = L.PatronId
                    WHERE L.Status = 'loaning'
                )";
                }
                else if (selectedValue == "Overdue")
                {
                    SqlDataSource1.SelectCommand = baseQuery + @"
                        AND [User].UserId IN (
                            SELECT DISTINCT CAST(U.UserId AS INT)
                            FROM [User] AS U
                            INNER JOIN Patron AS P ON U.UserId = P.UserId
                            INNER JOIN Loan AS L ON P.PatronId = L.PatronId
                            WHERE L.EndDate < CAST(GETDATE() AS DATE)
                            AND L.Status = 'loaning'
                        )";
                }
                else if (selectedValue == "Restricted")
                {
                    SqlDataSource1.SelectCommand = baseQuery + @"
                       AND Trustworthy.TrustLvl = 'Restricted'";
                }
                else
                {
                    SqlDataSource1.SelectCommand = baseQuery;
                }

                // Re-bind the GridView to apply the filter
                GridView1.DataBind();
            }
            catch (Exception ex)
            {
                ClientScript.RegisterStartupScript(this.GetType(), "alert", $"alert('Error: {ex.Message}');", true);
            }
        }
        protected void ddlFilter_SelectedIndexChanged(object sender, EventArgs e)
        {
            // Get the selected filter value
            string selectedValue = ddlFilter.SelectedValue;
            ViewState["SelectedFilter"] = selectedValue; // Update the ViewState with the new filter

            // Re-bind the GridView with the updated filter
            BindGrid();
        }

        protected void GridView1_RowEditing(object sender, GridViewEditEventArgs e)
        {
            // Set the edit index to the selected row
            GridView1.EditIndex = e.NewEditIndex;

            // Re-bind the GridView to apply the current filter in edit mode
            BindGrid();
        }

        protected void GridView1_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e)
        {
            // Cancel edit mode
            GridView1.EditIndex = -1;

            // Re-bind the GridView to apply the current filter
            GridView1.DataBind();
        }

        protected void GridView1_RowUpdating(object sender, GridViewUpdateEventArgs e)
        {
            // Update the user data in the data source
            SqlDataSource1.Update();

            // Reset the edit index
            GridView1.EditIndex = -1;

            // Re-bind the GridView with the current filter value from ViewState
            BindGrid();
        }

        [WebMethod]
        public static Result SendInboxMessage(int userId, string inboxTitle, string inboxContent)
        {
            try
            {
                string insertQuery = @"
            INSERT INTO Inbox (InboxTitle, InboxContent, UserId, SendAt, IsDelivered) 
            VALUES (@InboxTitle, @InboxContent, @UserId, GETDATE(), 0);
            SELECT SCOPE_IDENTITY();"; // Retrieve the newly inserted InboxId

                object[] insertParams = {
                    "@InboxTitle", inboxTitle,
                    "@InboxContent", inboxContent,
                    "@UserId", userId
                };

                // Execute the insert query and get the InboxId
                int newInboxId = Convert.ToInt32(DBHelper.ExecuteScalar(insertQuery, insertParams));

                if (newInboxId > 0)
                {
                    // Check if the user is online
                    string connectionId = NotificationHub.GetConnectionId(userId);

                    if (!string.IsNullOrEmpty(connectionId))
                    {
                        // Notify the user if they are online
                        var context = GlobalHost.ConnectionManager.GetHubContext<NotificationHub>();
                        context.Clients.Client(connectionId).broadcastInbox(inboxTitle, inboxContent, DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"));

                        // Update the message as delivered
                        string updateQuery = "UPDATE Inbox SET IsDelivered = 1 WHERE InboxId = @InboxId";
                        DBHelper.ExecuteNonQuery(updateQuery, new object[] { "@InboxId", newInboxId });
                    }

                }
                else
                {
                    throw new Exception("Failed to insert inbox message.");
                }

                return new Result { Success = true, Message = "Inbox message sent successfully!" };

            }
            catch (Exception ex)
            {
                return new Result { Success = false, Message = "An error occurred: " + ex.Message };
            }
        }
        public class Result
        {
            public bool Success { get; set; }
            public string Message { get; set; }
        }

        protected void GridView1_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "DownloadBarcode")
            {
                int userId = int.Parse(e.CommandArgument.ToString());
                GenerateAndDownloadQRCode(userId.ToString());
            }
        }

        private void GenerateAndDownloadQRCode(string userId)
        {
            try
            {
                // Create a QR code writer instance
                BarcodeWriter writer = new BarcodeWriter
                {
                    Format = BarcodeFormat.QR_CODE, // QR Code format
                    Options = new ZXing.Common.EncodingOptions
                    {
                        Width = 300, // Width of the QR Code
                        Height = 300, // Height of the QR Code
                        Margin = 10 // Margin around the QR Code
                    }
                };

                // Generate QR Code as a bitmap
                Bitmap qrCodeBitmap = writer.Write(userId);

                // Save to memory stream as PNG
                using (MemoryStream ms = new MemoryStream())
                {
                    qrCodeBitmap.Save(ms, ImageFormat.Png);
                    byte[] qrCodeBytes = ms.ToArray();

                    // Set response headers for file download
                    Response.Clear();
                    Response.ContentType = "image/png";
                    Response.AddHeader("Content-Disposition", $"attachment; filename=User_{userId}_QRCode.png");
                    Response.BinaryWrite(qrCodeBytes);
                    Response.End();
                }
            }
            catch (Exception ex)
            {
                // Handle exceptions
                Response.Write($"Error generating QR code: {ex.Message}");
            }
        }

    }
}
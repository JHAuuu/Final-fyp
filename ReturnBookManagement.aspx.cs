using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace fyp
{
    public partial class ReturnBookManagement : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static object verifyUserId(string userId)
        {
            string query = @"
        SELECT UserId, UserName 
        FROM [User] 
        WHERE UserId = @UserId AND IsDeleted = 0";

            string[] arr = new string[2];
            arr[0] = "@UserId";
            arr[1] = userId;

            try
            {
                // Execute the query
                DataTable resultTable = DBHelper.ExecuteQuery(query, arr);
                if (resultTable.Rows.Count > 0)
                {
                    // Get the user information from the query result
                    string userName = resultTable.Rows[0]["UserName"].ToString();
                    // Return valid status along with username
                    return new { status = "valid", username = userName };
                }
                else
                {
                    // User not found
                    return new { status = "invalid", message = "User not found." };
                }
            }
            catch (Exception ex)
            {
                // Log error or handle the exception as necessary
                return new { status = "error", message = ex.Message };
            }
        }

        protected void btnSubmit_Click(object sender, EventArgs e)
        {
            string userName = hfUserName.Value;
            string enteredPassword = submitPassword.Text.Trim();

            string query = @"
        SELECT UserId, UserName, UserPassword
        FROM [User] 
        WHERE userName = @userName AND IsDeleted = 0";

            string[] arr = new string[2];
            arr[0] = "@userName";
            arr[1] = userName;

            DataTable dt = DBHelper.ExecuteQuery(query, arr);

            // Check if user exists
            if (dt.Rows.Count > 0)
            {
                var userRow = dt.Rows[0];
                string storedPassword = userRow["UserPassword"].ToString();

                // Check if the entered password matches the stored password
                if (encryption.IsPasswordMatch(storedPassword, enteredPassword))
                {
                    // Set session and redirect if password matches
                    Session["ReturnUserId"] = userRow["UserId"].ToString();
                    Response.Redirect("ProcessReturn.aspx");
                }
                else
                {
                    // Show error if password does not match
                    ShowError("Invalid password. Please try again.");
                }
            }
            else
            {
                // If the user does not exist, show error message
                ShowError("User not found.");
            }
        }

        private void ShowError(string message)
        {
            // Send the error message to the client side (through JavaScript)
            ClientScript.RegisterStartupScript(this.GetType(), "PasswordError",
                $"alert('{message}'); clearModalData();", true);
        }
    }
}

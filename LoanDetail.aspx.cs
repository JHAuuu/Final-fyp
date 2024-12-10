using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace fyp
{
    public partial class LoanDetail : System.Web.UI.Page
    {
        static int userid = 0;
        public static int loanId = 0;
        public string recommended = "none";
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // Check if the "LoanId" query string parameter exists
                if (!string.IsNullOrEmpty(Request.QueryString["LoanId"]))
                {
                    // Retrieve the value of the "LoanId" query string parameter
                    loanId = Convert.ToInt32(Request.QueryString["LoanId"]);

                }

                if (Session["PatronId"] != null)
                {
                    userid = Convert.ToInt32(Session["PatronId"].ToString());
                }

                if(userid != 0 && loanId != 0)
                {
                    getLoan();
                }
                
            }
        }


        public void getLoan()
        {
            try
            {
                string query = @"SELECT 
    Loan.LoanId,
    Loan.StartDate,
    Loan.EndDate,
    Loan.IsApprove,
    Loan.PatronId,
    Loan.BookCopyId,
    Loan.Status,
    Loan.LatestReturn,
    Loan.IsCommented,
    Loan.Recommended,
    BookCopy.ISBN,
    BookCopy.BookId,
    BookCopy.BookCopyImage, -- Fields from BookCopy
    BookCopy.PublishDate, 
    BookCopy.PublishOwner, 
    Book.BookTitle,
    Book.BookDesc -- Fields from Book table, add more as needed 
FROM 
    Loan
INNER JOIN 
    BookCopy ON Loan.BookCopyId = BookCopy.BookCopyId
INNER JOIN 
    Book ON BookCopy.BookId = Book.BookId
WHERE 
    Loan.PatronId = @userId AND Loan.LoanId = @loanId";
                DataTable originalDt = DBHelper.ExecuteQuery(query, new string[]{
                    "userId", userid.ToString(),
                    "loanId",loanId.ToString()
                });

                if (originalDt.Rows.Count > 0)
                {
                    DataRow row = originalDt.Rows[0];

                    // Assign values using GetSafeValue
                    lblBookTitle.Text = GetSafeValue(row, "BookTitle");
                    lblISBN.Text = GetSafeValue(row, "ISBN");
                    lblStartDate.Text = !string.IsNullOrEmpty(GetSafeValue(row, "StartDate"))
                        ? DateTime.Parse(GetSafeValue(row, "StartDate")).ToString("dd MMM yyyy")
                        : "N/A";
                    lblEndDate.Text = !string.IsNullOrEmpty(GetSafeValue(row, "EndDate"))
                        ? DateTime.Parse(GetSafeValue(row, "EndDate")).ToString("dd MMM yyyy")
                        : "N/A";
                    lblPubDate.Text = !string.IsNullOrEmpty(GetSafeValue(row, "PublishDate"))
                        ? DateTime.Parse(GetSafeValue(row, "PublishDate")).ToString("dd MMM yyyy")
                        : "N/A";
                    lblOwner.Text = GetSafeValue(row, "PublishOwner");

                    // Handle status
                    string status = GetSafeValue(row, "Status").ToLower();
                    switch (status)
                    {
                        case "loaning":
                            lblStatus.Text = "Loaning";
                            break;
                        case "latereturn":
                            lblStatus.Text = "Late Return";
                            break;
                        case "returned":
                            lblStatus.Text = "Returned";
                            break;
                        default:
                            lblStatus.Text = "Unknown";
                            break;
                    }

                    // Handle LatestReturn
                    lblLatestReturn.Text = !string.IsNullOrEmpty(GetSafeValue(row, "LatestReturn"))
                        ? DateTime.Parse(GetSafeValue(row, "LatestReturn")).ToString("dd MMM yyyy")
                        : "N/A";

                    // Handle Days Left to Return
                    if (!status.Equals("returned", StringComparison.OrdinalIgnoreCase))
                    {
                        DateTime startDate = DateTime.Parse(GetSafeValue(row, "StartDate"));
                        DateTime endDate = DateTime.Parse(GetSafeValue(row, "EndDate"));
                        int daysDifference = (endDate - startDate).Days;

                        if (daysDifference <= 7)
                        {
                            pnlExtendDate.Visible = true;
                        }
                        else
                        {
                            pnlExtendDate.Visible = false;
                        }

                        if (daysDifference >= 0)
                        {
                            lblDaysLeftToReturn.Text = $"{Math.Abs(daysDifference)} days left to return";
                            pnlDaysLeftToReturn.Visible = true;
                            
                        }
                        else
                        {
                            pnlDaysLeftToReturn.Visible = false;
                           
                        }
                    }
                    else
                    {
                        pnlDaysLeftToReturn.Visible = false;
                        pnlExtendDate.Visible = false;
                    }

                    string recommendedValue = GetSafeValue(row, "Recommended");
                    if (string.IsNullOrEmpty(recommendedValue))
                    {
                        recommended = "none"; // None of the buttons are active
                    }
                    else if (recommendedValue == "True")
                    {
                        recommended = "up"; // Up button active
                    }
                    else if (recommendedValue == "False")
                    {
                        recommended = "down"; // Down button active
                    }

                    string getCommented = (GetSafeValue(row, "IsCommented"));
                    if(status == "returned" && getCommented == "False")
                    {
                       
                            pnlComment.Visible = true; // Down button active
                        
                    }
                    else
                    {
                        pnlComment.Visible = false;
                    }



                    imgBook.ImageUrl = row["BookCopyImage"] != DBNull.Value ? ImageHandler.GetImage((byte[])row["BookCopyImage"]) : "images/defaultCoverBook.png";

                    

                }


            }
            catch (Exception ex)
            {
                
            }
        }

        [System.Web.Services.WebMethod(Description = "Update Date")]
        public static string ExtendDate(string loanId)
        {
            try
            {
                string getDateDuery = "SELECT StartDate, EndDate FROM Loan WHERE LoanId = @loanId";
                DataTable dt = DBHelper.ExecuteQuery(getDateDuery, new string[]{
                    "loanId", loanId
                });

                if (dt.Rows.Count > 0)
                {
                    // Step 2: Convert StartDate and EndDate to DateTime
                    DateTime startDate = Convert.ToDateTime(dt.Rows[0]["StartDate"]).Date;
                    DateTime endDate = Convert.ToDateTime(dt.Rows[0]["EndDate"]).Date;

                    // Step 3: Compare dates to check if remaining days are 7 or fewer
                    int daysLeft = (endDate - startDate).Days;

                    if (daysLeft <= 7)
                    {
                        // Step 4: Add 7 days to EndDate
                        DateTime newEndDate = endDate.AddDays(7);

                        // Step 5: Update query to set the new EndDate
                        string updateQuery = "UPDATE Loan SET EndDate = @newEndDate WHERE LoanId = @loanId";

                        // Execute the update query
                        int updateSuccess = DBHelper.ExecuteNonQuery(updateQuery, new string[]
                        {
                "newEndDate", newEndDate.ToString("yyyy-MM-dd"),
                "loanId", loanId
                        });

                        if (updateSuccess > 0)
                        {
                            return "SUCCESS";
                        }
                        else
                        {
                            return "Failed to Extend Date";
                        }
                    }
                    else
                    {
                        return "You already extended the date or you choosing longer than 7 days.";
                    }
                }
                else
                {
                    return "There is no such data";
                }

            }
            catch (Exception ex)
            {
                return $"Error: {ex.Message}";
            }
        }


        [System.Web.Services.WebMethod(Description = "Book Recommended")]
        public static void bookRecommended()
        {
            try
            {
                string query = @"UPDATE Loan
SET Recommended = 1
WHERE LoanId = @loanId
AND PatronId = @userId;";
                DataTable originalDt = DBHelper.ExecuteQuery(query, new string[]{
                    "userId", userid.ToString(),
                    "loanId",loanId.ToString()
                });
            }catch(Exception ex)
            {

            }
            
        }

        [System.Web.Services.WebMethod(Description = "Book Not Recommended")]
        public static void bookNotRecommended()
        {
            try
            {
                string query = @"UPDATE Loan
SET Recommended = 0
WHERE LoanId = @loanId
AND PatronId = @userId;";
                DataTable originalDt = DBHelper.ExecuteQuery(query, new string[]{
                    "userId", userid.ToString(),
                    "loanId",loanId.ToString()
                });
            }
            catch (Exception ex)
            {

            }

        }

        public string GetBookId()
        {
            int bookId = 0;

            // Retrieve the BookId from the database when the loan details are loaded
            if (loanId != 0)
            {
                // Assuming you have a method to fetch the BookId from the database using the loanId
                string query = "SELECT BookCopy.BookId FROM Loan INNER JOIN BookCopy ON Loan.BookCopyId = BookCopy.BookCopyId WHERE Loan.LoanId = @loanId AND Loan.PatronId = @userId";
                bookId = Convert.ToInt32(DBHelper.ExecuteScalar(query, new string[] { 
                    "loanId", loanId.ToString(), 
                    "userId", userid.ToString() 
                }));

                if (bookId != 0)
                {
                    return bookId.ToString();
                }
            }
            return null;

        }

        private string GetSafeValue(DataRow row, string columnName)
        {
            return row[columnName] != DBNull.Value ? row[columnName].ToString() : string.Empty;
        }
    }
}
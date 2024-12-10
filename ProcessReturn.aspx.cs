using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.Services;
using System.Data;
using System.Data.SqlClient;

namespace fyp
{
    public partial class ProcessReturn : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                int userId;
                if (!string.IsNullOrEmpty(Session["ReturnUserId"].ToString()))
                {
                    userId = Convert.ToInt32(Session["ReturnUserId"].ToString());
                    BindLoanData(userId);
                }
                else
                {
                    NoRecords.Visible = true;
                    Repeater1.Visible = false;
                }
            }
        }

        private void BindLoanData(int userId)
        {
            // Query to get loan data
            string query = @"
                SELECT L.LoanId, L.StartDate, L.EndDate, U.UserName, B.BookTitle, BC.ISBN, L.Status 
                FROM Loan L
                INNER JOIN Patron P ON L.PatronId = P.PatronId 
                INNER JOIN [User] U ON P.UserId = U.UserId 
                INNER JOIN BookCopy BC ON L.BookCopyId = BC.BookCopyId 
                INNER JOIN Book B ON BC.BookId = B.BookId 
                WHERE U.UserId = @UserId AND L.Status = 'loaning'";

            try
            {
                // Assuming DBHelper.ExecuteQuery takes a query and parameters array and returns a DataTable
                DataTable resultTable = fyp.DBHelper.ExecuteQuery(query, new object[] { "@UserId", userId });

                // Check if the resultTable has any rows
                if (resultTable != null && resultTable.Rows.Count > 0)
                {
                    Repeater1.DataSource = resultTable;
                    Repeater1.DataBind();
                    NoRecords.Visible = false;
                    Repeater1.Visible = true;
                }
                else
                {
                    // No data found
                    NoRecords.Visible = true;
                    Repeater1.Visible = false;
                    NoRecords.InnerText = "No active loans found. You don't have any books to return.";
                }
            }
            catch (Exception ex)
            {
                // Handle exceptions and show error message
                NoRecords.Visible = true;
                Repeater1.Visible = false;
                NoRecords.InnerText = $"An error occurred: {ex.Message}";
            }
        }

        protected void Repeater1_PreRender(object sender, EventArgs e)
        {
            if (Repeater1.Items.Count < 1)
            {
                NoRecords.Visible = true;
                Repeater1.Visible = false;
            }
            else
            {
                NoRecords.Visible = false;
                Repeater1.Visible = true;
            }
        }

        [WebMethod]
        public static string HandleReturnProcess(string isbn)
        {
            string connectionString = System.Configuration.ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;

            try
            {
                using (SqlConnection connection = new SqlConnection(connectionString))
                {
                    connection.Open();

                    // Get the loan ID, patron ID, and other details using the ISBN
                    string query = @"
            SELECT L.LoanId, L.PatronId, L.EndDate, P.TotalFine, P.DatePayed, BC.BookCopyId, T.TrustScore
            FROM Loan L
            INNER JOIN BookCopy BC ON L.BookCopyId = BC.BookCopyId
            LEFT JOIN Punishment P ON L.LoanId = P.LoanId
            LEFT JOIN Trustworthy T ON L.PatronId = T.PatronId
            WHERE BC.ISBN = @ISBN AND L.Status = 'loaning'";

                    using (SqlCommand command = new SqlCommand(query, connection))
                    {
                        command.Parameters.AddWithValue("@ISBN", isbn);

                        using (SqlDataReader reader = command.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                int loanId = reader.GetInt32(0);
                                int patronId = reader.GetInt32(1);
                                DateTime endDate = reader.GetDateTime(2);
                                decimal? totalFine = reader.IsDBNull(3) ? (decimal?)null : reader.GetDecimal(3);
                                DateTime? datePayed = reader.IsDBNull(4) ? (DateTime?)null : reader.GetDateTime(4);
                                int bookCopyId = reader.GetInt32(5);
                                int currentTrustScore = reader.GetInt32(6);

                                reader.Close();

                                // Update Loan table: Set LatestReturn and Status to 'returned'
                                DateTime today = DateTime.Today;

                                string updateLoanQuery = @"
                        UPDATE Loan
                        SET LatestReturn = @Today, Status = 'returned'
                        WHERE LoanId = @LoanId";

                                using (SqlCommand updateLoanCommand = new SqlCommand(updateLoanQuery, connection))
                                {
                                    updateLoanCommand.Parameters.AddWithValue("@Today", today);
                                    updateLoanCommand.Parameters.AddWithValue("@LoanId", loanId);
                                    updateLoanCommand.ExecuteNonQuery();
                                }

                                // Update BookCopy table: Set IsAvailable to true
                                string updateBookCopyQuery = @"
                        UPDATE BookCopy
                        SET IsAvailable = 1
                        WHERE BookCopyId = @BookCopyId";

                                using (SqlCommand updateBookCopyCommand = new SqlCommand(updateBookCopyQuery, connection))
                                {
                                    updateBookCopyCommand.Parameters.AddWithValue("@BookCopyId", bookCopyId);
                                    updateBookCopyCommand.ExecuteNonQuery();
                                }

                                // Calculate TrustScore adjustment
                                int trustScoreAdjustment;
                                if (today > endDate)
                                {
                                    // Late return: Deduct TrustScore based on days late
                                    int daysLate = (today - endDate).Days;

                                    if (daysLate <= 3)
                                    {
                                        trustScoreAdjustment = -2; // Deduct 2 points for 1-3 days late
                                    }
                                    else if (daysLate <= 7)
                                    {
                                        trustScoreAdjustment = -5; // Deduct 5 points for 4-7 days late
                                    }
                                    else
                                    {
                                        trustScoreAdjustment = -10; // Deduct 10 points for 8+ days late
                                    }
                                }
                                else if (currentTrustScore < 120) // Check if TrustScore is less than 120
                                {
                                    // On-time or early return: Add TrustScore
                                    trustScoreAdjustment = 3; // Add 3 points for good behavior

                                    // Ensure the TrustScore does not exceed 120
                                    if (currentTrustScore + trustScoreAdjustment > 120)
                                    {
                                        trustScoreAdjustment = 120 - currentTrustScore; // Adjust the points so that the total does not exceed 120
                                    }

                                    // Now apply the adjusted TrustScore
                                    currentTrustScore += trustScoreAdjustment;
                                }
                                else
                                {
                                    trustScoreAdjustment = 0; // No increase if TrustScore is already 120
                                }

                                // Update TrustScore
                                string updateTrustScoreQuery = @"
                        UPDATE Trustworthy
                        SET TrustScore = CASE 
                            WHEN TrustScore + @Adjustment > 120 THEN 120
                            WHEN TrustScore + @Adjustment < 0 THEN 0
                            ELSE TrustScore + @Adjustment
                        END
                        WHERE PatronId = @PatronId";

                                using (SqlCommand updateTrustScoreCommand = new SqlCommand(updateTrustScoreQuery, connection))
                                {
                                    updateTrustScoreCommand.Parameters.AddWithValue("@Adjustment", trustScoreAdjustment);
                                    updateTrustScoreCommand.Parameters.AddWithValue("@PatronId", patronId);
                                    updateTrustScoreCommand.ExecuteNonQuery();
                                }

                                return $"The book with ISBN: {isbn} has been successfully returned. " +
                                       (trustScoreAdjustment < 0
                                           ? $"Since you returned late, your TrustScore was reduced by {-trustScoreAdjustment} points."
                                           : trustScoreAdjustment > 0
                                               ? $"Thank you for returning on time! Your TrustScore increased by {trustScoreAdjustment} points."
                                               : $"Thank you for returning on time! Your TrustScore remains at the maximum of 120.") +
                                       (totalFine.HasValue && !datePayed.HasValue
                                           ? $" You also need to pay a fine of RM{totalFine}. Please log in to settle the fine."
                                           : "");
                            }
                            else
                            {
                                return "No active loan found for this ISBN.";
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                return $"Error: {ex.Message}";
            }
        }

        protected void btnViewHistory_Click(object sender, EventArgs e)
        {
            Response.Redirect($"ReturnHistory.aspx");
        }

        protected void logOut_Click(object sender, EventArgs e)
        {
            Session["ReturnUserId"] = null;

            Response.Redirect("ReturnBookManagement.aspx");
        }

    }
}
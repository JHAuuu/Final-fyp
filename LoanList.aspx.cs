using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace fyp
{
    public partial class LoanList : UserPage
    {
        static int userid = 0;
        public int userTrustValue = 0;
        public string userTrustLevel = "";
        public static decimal totalFine;
        static string role;
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (!string.IsNullOrEmpty(Session["UserRole"].ToString()))
                {
                    role = Session["UserRole"].ToString();
                }
                else
                {
                    role = "";
                }

                if (Session["PatronId"] != null)
                {
                    userid = Convert.ToInt32(Session["PatronId"].ToString());

                    DataTable getLoan = getAllLoan();
                    if(getLoan.Rows.Count > 0)
                    {
                        rptLoan.DataSource = getLoan;
                        rptLoan.DataBind();
                    }
                    DataTable getPunish = getAllPunishment();
                    if (getPunish.Rows.Count > 0)
                    {
                        rptPunishment.DataSource = getPunish;
                        rptPunishment.DataBind();
                    } 
                    DataTable notReturnData = getAllNotReturn();
                    if (notReturnData.Rows.Count > 0)
                    {
                        rptNotReturn.DataSource = notReturnData;
                        rptNotReturn.DataBind();
                    }

                    getUserTrust();
                }
                else
                {
                    Response.Redirect("Home.aspx");
                }
            }

        }

        public DataTable getAllLoan()
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
    BookCopy.ISBN,
    BookCopy.BookId,
    BookCopy.BookCopyImage, -- Fields from BookCopy
    Book.BookTitle,
    Book.BookDesc -- Fields from Book table, add more as needed
FROM 
    Loan
INNER JOIN 
    BookCopy ON Loan.BookCopyId = BookCopy.BookCopyId
INNER JOIN 
    Book ON BookCopy.BookId = Book.BookId
WHERE 
    Loan.PatronId = @userId
    AND (Loan.Status = 'loaning') AND CAST(GETDATE() AS DATE) <= CAST(Loan.EndDate AS DATE) AND Loan.LatestReturn IS NULL;";
                DataTable originalDt = DBHelper.ExecuteQuery(query, new string[]{
                    "userId", userid.ToString()
                });


                DataTable dt = new DataTable();
                dt.Columns.Add("LoanId", typeof(string));
                dt.Columns.Add("StartDate", typeof(string));
                dt.Columns.Add("EndDate", typeof(string));
                dt.Columns.Add("IsApprove", typeof(string));
                dt.Columns.Add("PatronId", typeof(string));
                dt.Columns.Add("BookCopyId", typeof(string));
                dt.Columns.Add("Status", typeof(string));
                dt.Columns.Add("ISBN", typeof(string));
                dt.Columns.Add("BookId", typeof(string));
                dt.Columns.Add("BookCopyImage", typeof(string));
                dt.Columns.Add("BookTitle", typeof(string));
                dt.Columns.Add("BookDesc", typeof(string));

                if(originalDt.Rows.Count > 0)
                {
                    foreach (DataRow originalRow in originalDt.Rows)
                    {
                        DataRow newRow = dt.NewRow();
                        foreach (DataColumn column in originalDt.Columns)
                        {
                            if (originalRow[column] != DBNull.Value)
                            {
                                if (column.ColumnName == "BookCopyImage")
                                {

                                    newRow[column.ColumnName] = ImageHandler.GetImage((byte[])originalRow[column]);
                                }
                                else if (column.ColumnName == "StartDate" || column.ColumnName == "EndDate")
                                {
                                    newRow[column.ColumnName] = DateTime.Parse(originalRow[column].ToString()).ToString("yyyy-MM-dd"); ;
                                }
                                else
                                {
                                    newRow[column.ColumnName] = originalRow[column].ToString();
                                }

                            }
                            else
                            {
                                newRow[column.ColumnName] = DBNull.Value;
                            }

                        }
                        dt.Rows.Add(newRow);
                    }

                    loanEmptyMessage.Visible = false;
                    return dt;
                }
                else
                {
                    loanEmptyMessage.Visible = true;
                    return new DataTable();
                }
                

                

            }catch(Exception ex)
            {
                loanEmptyMessage.Visible = true;
                return new DataTable();
            }
        }

        public void getUserTrust()
        {
            try
            {
                string query = @"SELECT TrustId
      ,TrustScore
      ,TrustLvl
  FROM Trustworthy
WHERE PatronId = @userId
";
                DataTable originalDt = DBHelper.ExecuteQuery(query, new string[]{
                    "userId", userid.ToString()
                });


                if (originalDt.Rows.Count > 0)
                {
                    // Retrieve the first row (assuming one result per user)
                    DataRow dtRow = originalDt.Rows[0];

                    // Access the values as needed
                    int trustId = Convert.ToInt32(dtRow["TrustId"]);
                    userTrustValue = Convert.ToInt32(dtRow["TrustScore"]);
                    

                    if (userTrustValue >= 80 && userTrustValue < 90)
                    {
                        userTrustLevel = $"You can only have 1 book to borrow on trust of {userTrustValue} credit.";

                    }
                    else if (userTrustValue >= 90 && userTrustValue < 100)
                    {
                        userTrustLevel = $"You can only have 2 book to borrow on trust of {userTrustValue} credit.";
                    }
                    else if (userTrustValue >= 100 && userTrustValue < 120)
                    {
                        userTrustLevel = $"You can only have 3 book to borrow on trust of {userTrustValue} credit.";
                    }
                    else if (userTrustValue == 120)
                    {
                        if (role == "Teacher")
                        {
                            userTrustLevel = $"You can only have 5 book to borrow on trust of {userTrustValue} credit.";
                        }
                        else
                        {
                            userTrustLevel = $"You can only have 3 book to borrow on trust of {userTrustValue} credit.";
                        }
                        
                    }
                    else
                    {
                        userTrustLevel = $"You are not trusted below the 80 credit trust, you are not allowed to borrow a single book on trust of  {userTrustValue} credit.";
                    }
                }




                }
            catch (Exception ex)
            {
             
            }
        }

        public DataTable getAllPunishment()
        {
            try
            {
                string query = @"SELECT 
    p.LoanId, 
    p.TotalFine, 
    l.LatestReturn, 
    p.DatePayed, 
    p.PunishStatus,
    l.StartDate, 
    l.EndDate, 
    l.Status, 
    bc.ISBN,
    bc.BookCopyId, 
    bc.BookCopyImage, 
    b.BookTitle
FROM Punishment p
JOIN Loan l ON p.LoanId = l.LoanId
JOIN BookCopy bc ON l.BookCopyId = bc.BookCopyId
JOIN Book b ON bc.BookId = b.BookId
WHERE l.PatronId = @userId
  AND p.PunishStatus = 'Unpaid'
AND l.LatestReturn IS NOT NULL;

";
                DataTable originalDt = DBHelper.ExecuteQuery(query, new string[]{
                    "userId", userid.ToString()
                });

                DataTable dt = new DataTable();
                dt.Columns.Add("LoanId", typeof(string));
                dt.Columns.Add("TotalFine", typeof(string));
                dt.Columns.Add("LatestReturn", typeof(string));
                dt.Columns.Add("DatePayed", typeof(string));
                dt.Columns.Add("PunishStatus", typeof(string));
                dt.Columns.Add("StartDate", typeof(string));
                dt.Columns.Add("EndDate", typeof(string));
                dt.Columns.Add("Status", typeof(string));
                dt.Columns.Add("ISBN", typeof(string));
                dt.Columns.Add("BookCopyId", typeof(string));
                dt.Columns.Add("BookCopyImage", typeof(string));
                dt.Columns.Add("BookTitle", typeof(string));


                totalFine = 0;

                if (originalDt.Rows.Count > 0)
                {
                    foreach (DataRow originalRow in originalDt.Rows)
                    {
                        DataRow newRow = dt.NewRow();
                        foreach (DataColumn column in originalDt.Columns)
                        {

                            if (column.ColumnName == "TotalFine" && originalRow[column] != DBNull.Value)
                            {
                                decimal fine = Convert.ToDecimal(originalRow[column]);
                                totalFine += fine;  // Add to total fine sum
                                newRow[column.ColumnName] = fine.ToString("F2");
                            }      
                            else if(originalRow[column] != DBNull.Value)
                            {
                                if (column.ColumnName == "BookCopyImage")
                                {

                                    newRow[column.ColumnName] = ImageHandler.GetImage((byte[])originalRow[column]);
                                }
                                else if (column.ColumnName == "LatestReturn")
                                {
                                    newRow[column.ColumnName] = "Returned on " + DateTime.Parse(originalRow[column].ToString()).ToString("yyyy-MM-dd");
                                }
                                else
                                
                                {
                                    newRow[column.ColumnName] = originalRow[column].ToString();
                                }
                            }
                            else
                            {
                                newRow[column.ColumnName] = DBNull.Value;
                            }
                           

                       

                        }
                        dt.Rows.Add(newRow);
                    }

                    punishmentEmptyMessage.Visible = false;
                    return dt;
                    
                }
                else
                {
                    punishmentEmptyMessage.Visible = true;
                    return new DataTable();
                    // Show the empty message if no data is available
                    
                }
            
                

            }
            catch (Exception ex)
            {
                punishmentEmptyMessage.Visible = true;
                return new DataTable();
            }
        }
        
        public DataTable getAllNotReturn()
        {
            try
            {
                string query = @"SELECT 
    l.StartDate, 
    l.EndDate, 
    l.Status, 
    bc.ISBN, 
    bc.BookCopyId, 
    bc.BookCopyImage, 
    b.BookTitle
FROM Loan l 
JOIN BookCopy bc ON l.BookCopyId = bc.BookCopyId
JOIN Book b ON bc.BookId = b.BookId
WHERE l.PatronId = @userId
AND l.LatestReturn IS NULL
AND CAST(GETDATE() AS DATE) > CAST(EndDate AS DATE);

";
                DataTable originalDt = DBHelper.ExecuteQuery(query, new string[]{
                    "userId", userid.ToString()
                });

                DataTable dt = new DataTable();
                dt.Columns.Add("LatestReturn", typeof(string));
                dt.Columns.Add("StartDate", typeof(string));
                dt.Columns.Add("EndDate", typeof(string));
                dt.Columns.Add("Status", typeof(string));
                dt.Columns.Add("ISBN", typeof(string));
                dt.Columns.Add("BookCopyId", typeof(string));
                dt.Columns.Add("BookCopyImage", typeof(string));
                dt.Columns.Add("BookTitle", typeof(string));


        
                if (originalDt.Rows.Count > 0)
                {
                    foreach (DataRow originalRow in originalDt.Rows)
                    {
                        DataRow newRow = dt.NewRow();
                        foreach (DataColumn column in originalDt.Columns)
                        {

                            
                            if(originalRow[column] != DBNull.Value)
                            {
                                if (column.ColumnName == "BookCopyImage")
                                {

                                    newRow[column.ColumnName] = ImageHandler.GetImage((byte[])originalRow[column]);
                                }
                                else
                                {
                                    newRow[column.ColumnName] = originalRow[column].ToString();
                                }
                            }
                            else
                            {
                                newRow[column.ColumnName] = DBNull.Value;
                            }
                           

                       

                        }
                        dt.Rows.Add(newRow);
                    }

                    
                    return dt;
                    
                }
                else
                {
                    
                    return new DataTable();
                    
                    
                }
            
                

            }
            catch (Exception ex)
            {
                return new DataTable();
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
            catch(Exception ex)
            {
                return $"Error: {ex.Message}";
            }
        }

        [System.Web.Services.WebMethod(Description = "Check Trustworthy")]
        public static string checkTrustLevel()
        {
            try
            {
                string trustQuery = @"SELECT TrustScore
  FROM Trustworthy
  WHERE PatronId = @userId
";

                string checkLoanQuery = @"SELECT COUNT(LoanId)
  FROM Loan
  WHERE PatronId = @userId AND Status = 'loaning'

";
                object getTrustScore = DBHelper.ExecuteScalar(trustQuery, new string[]
                {
                    "userId", userid.ToString()
                });

                object getLoanNum = DBHelper.ExecuteScalar(checkLoanQuery, new string[]
                {
                    "userId", userid.ToString()
                });

                int userScore = Convert.ToInt32(getTrustScore);

                int userLoanNum = Convert.ToInt32(getLoanNum);

                if (userScore >= 80 && userScore < 90)
                {
                    if (userLoanNum < 1)
                    {
                        return "SUCCESS";
                    }
                    else
                    {
                        return "You cannot borrow more than 1 books on " + userScore.ToString() + " trust credit";
                    }

                }
                else if (userScore >= 90 && userScore < 100)
                {
                    if (userLoanNum < 2)
                    {
                        return "SUCCESS";
                    }
                    else
                    {
                        return "You cannot borrow more than 2 books on " + userScore.ToString() + " trust credit";
                    }
                }
                else if (userScore >= 100 && userScore < 120)
                {
                    if (userLoanNum < 3)
                    {
                        return "SUCCESS";
                    }
                    else
                    {
                        return "You cannot borrow more than 3 books on " + userScore.ToString() + " trust credit";
                    }
                }else if (userScore == 120)
                {
                    if (role == "Teacher")
                    {
                        if (userLoanNum < 5)
                        {
                            return "SUCCESS";
                        }
                        else
                        {
                            return "You cannot borrow more than 5 books on " + userScore.ToString() + " trust credit";
                        }
                    }
                    else
                    {
                        if (userLoanNum < 3)
                        {
                            return "SUCCESS";
                        }
                        else
                        {
                            return "You cannot borrow more than 3 books on " + userScore.ToString() + " trust credit";
                        }
                    }

                   
                }
                else
                {
                    return userScore.ToString() + " is not in the range of trust credit";
                }
            }
            catch (Exception ex)
            {
                return "Error retrieving trust data";
            }
        }


        protected void btnPaymentStart_Click(object sender, EventArgs e)
        {
            try
            {
                PaymentDetails pd = new PaymentDetails();

                Random zufall = new Random();
                DateTime dt = DateTime.Now;
                string invoiceNumber = dt.Year.ToString() + dt.Month.ToString() + dt.Day.ToString() + dt.Hour.ToString() + dt.Minute.ToString() + dt.Second.ToString() + Convert.ToString(zufall.Next(-100, 100)).PadLeft(2, '0');
                pd.Set("InvoiceNumber", invoiceNumber);
                pd.Set("ItemDescription", "Payment Detail Description");
                pd.Set("ItemName", "Payment For Student Late Return Punishment");
                pd.Set("Quantity", "1");
                pd.Set("Total", totalFine.ToString());
                pd.Set("Execute", "command to execute after payment");

                PaymentPrepare pp = new PaymentPrepare();
                pp.PaymentDetails = pd;
                pp.Description = "Student has return their books and paid for the fine of late return";
                string baseUrl = Request.Url.ToString().Substring(0, Request.Url.ToString().LastIndexOf("/"));
                pp.UrlCancel = baseUrl + "/LoanList.aspx";
                pp.UrlReturn = baseUrl + "/LoanList.aspx";

                string removeAllPunish = payForPunishment();

                if (removeAllPunish == "SUCCESS")
                {
                    var payment = pp.CreatePayment();
                    string paymentId = payment.id;
                    pd.Set(pd.PaymentId, paymentId);
                    Session[paymentId] = pd;
                    lblErrorMessage.Visible = false;
                    Response.Redirect(payment.GetApprovalUrl());
                }
                else
                {
                    lblErrorMessage.Visible = true;
                    lblErrorMessage.Text = removeAllPunish;
                }
            }catch(Exception ex)
            {
                lblErrorMessage.Visible = true;
                lblErrorMessage.Text = ex.ToString();
            }
            
            

        }


        public string payForPunishment()
        {
            try
            {
                string query = @"UPDATE Punishment
SET PunishStatus = 'Paid',
    DatePayed = GETDATE() 
WHERE LoanId IN (
    SELECT p.LoanId
    FROM Punishment p
    JOIN Loan l ON p.LoanId = l.LoanId
    WHERE l.PatronId = @userId
      AND p.PunishStatus = 'Unpaid'
    AND l.LatestReturn IS NOT NULL
);";
                int updatePunish = DBHelper.ExecuteNonQuery(query, new string[] {
                    "userId", userid.ToString()
                });

                if(updatePunish > 0)
                {
                    string scoreQuery = @"UPDATE T
SET T.TrustScore = 
    CASE 
        WHEN U.UserRole = 'Student' AND T.TrustScore + 1 > 100 THEN 100
        WHEN U.UserRole = 'Teacher' AND T.TrustScore + 1 > 120 THEN 120
        ELSE T.TrustScore + 1
    END
FROM [fypDatabase].[dbo].[Trustworthy] T
JOIN Patron P ON T.PatronId = P.PatronId
JOIN [User] U ON P.UserId = U.UserId
WHERE T.PatronId = @userId;";

                    int updateScore = DBHelper.ExecuteNonQuery(scoreQuery, new string[] {
                    "userId", userid.ToString()
                });
                    if(updateScore > 0)
                    {
                        return "SUCCESS";
                    }
                    else
                    {
                        return "Fail to add score";
                    }
                    
                }
                else
                {
                    return "Failed to remove punishments";
                }
            }
            catch(Exception ex)
            {
                return "Something went wrong";
            }
        }

        protected string ShowExtendDateButton(object startDateObj, object endDateObj, object loanIdObj)
        {
            try
            {
                // Safely parse StartDate and EndDate to DateTime
                DateTime startDate = Convert.ToDateTime(startDateObj).Date;
                DateTime endDate = Convert.ToDateTime(endDateObj).Date;

                // Calculate the remaining days
                var daysLeft = (endDate - startDate).Days;

                // Check if the button should be displayed
                if (daysLeft <= 7 && loanIdObj != null)
                {
                    return $"<button style='width: 125px; padding: 5px 10px;' onclick=\"extendDate('{loanIdObj}')\">Extend Date</button>";
                }
            }
            catch (Exception ex)
            {
                // Log the exception or handle it appropriately
                // For debugging:
                throw new InvalidOperationException("Error generating Extend Date button", ex);
            }

            return string.Empty;
        }
    }
}
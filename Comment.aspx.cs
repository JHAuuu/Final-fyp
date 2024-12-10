using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace fyp
{
    public partial class Comment : System.Web.UI.Page
    {
        static int userid = 0;
        static int bookId = 0;
        static int loanId = 0;
        static string rateDate;


        public int rateStars = 0;
        public string rateComment;
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["PatronId"] != null)
            {

                userid = Convert.ToInt32(Session["PatronId"].ToString());

                if (!string.IsNullOrEmpty(Request.QueryString["bookId"]))
                {
                    bookId = Convert.ToInt32(Request.QueryString["bookId"]);

                    if (string.IsNullOrEmpty(Request.QueryString["date"]) && string.IsNullOrEmpty(Request.QueryString["loanId"]))
                    {
                        Response.Redirect("error/404PageNotFound.aspx");
                    }

                    if (!string.IsNullOrEmpty(Request.QueryString["loanId"]))
                    {
                        loanId = Convert.ToInt32(Request.QueryString["loanId"]);
                        string checkLoan = @"SELECT COUNT(LoanId) FROM Loan
WHERE 
    LoanId = @loanId";
                        int getLoan = Convert.ToInt32(DBHelper.ExecuteScalar(checkLoan,new string[]
                        {
                            "loanId", loanId.ToString()
                        }));

                        if(getLoan == 0)
                        {
                            Response.Redirect("error/404PageNotFound.aspx");
                        }
                    }
                    else
                    {
                        loanId = 0;

                    }

                    if (!string.IsNullOrEmpty(Request.QueryString["date"]))
                    {
                        rateDate = DateTime.Parse(Request.QueryString["date"]).ToString("yyyy-MM-dd HH:mm:ss");
                        string query = @"   SELECT PatronId, BookId, RateComment, RateStarts, RateDate
    FROM Rating
    WHERE PatronId = @userId
    AND BookId = @bookId
    AND CONVERT(VARCHAR(19), RateDate, 120) = @date";
                        
                        DataTable dt = DBHelper.ExecuteQuery(query, new string[]{

                            "userId",userid.ToString(),
                            "bookId",bookId.ToString(),
                            "date",rateDate

                        });

                        if (dt.Rows.Count > 0)
                        {
                            DataRow dtRow = dt.Rows[0];

                            rateComment = dtRow["RateComment"].ToString().Trim();
                            rateStars = Convert.ToInt32(dtRow["RateStarts"]);


                        }else
                        {
                            Response.Redirect("error/404PageNotFound.aspx");

                        }
                        

                    }
                }
            }
            else
            {
                Response.Redirect("Logout.aspx");
            }
            
        }

        [System.Web.Services.WebMethod(Description = "Submit Comment")]
        public static string SubmitComment(int rating, string comment)
        {
            try
            {
            
             
                if(loanId != 0)
                {
                    string query = @"INSERT INTO Rating (PatronId, BookId, RateComment, RateStarts, RateDate)
VALUES
(@userId, @bookId, @comment, @rating, GETDATE())";

                    int insertData = DBHelper.ExecuteNonQuery(query, new string[]{
                        "userId", userid.ToString(),
                        "bookId",bookId.ToString(),
                        "comment",comment,
                        "rating",rating.ToString()
                    });

                    if(insertData > 0)
                    {
                        string updateLoan = @"UPDATE Loan
SET 
    IsCommented = 1
WHERE 
    LoanId = @loanId";

                        int updatedLoan = DBHelper.ExecuteNonQuery(updateLoan, new string[]{
                        "loanId", loanId.ToString(),
                    });

                        if(updatedLoan > 0)
                        {
                            return "SUCCESS";
                        }
                        else
                        {
                            return "Fail to create the comment";
                        }
                    }
                    else
                    {
                        return "Fail to create the comment";
                    }
                }
                else
                {
                    string query = @"UPDATE Rating
SET 
    RateComment = @comment,
    RateStarts = @rating
WHERE 
    PatronId = @userId AND BookId = @bookId AND CONVERT(VARCHAR(19), RateDate, 120) = @date";

                    int insertData = DBHelper.ExecuteNonQuery(query, new string[]{
                        "userId", userid.ToString(),
                        "bookId",bookId.ToString(),
                        "comment",comment,
                        "rating",rating.ToString(),
                        "date", rateDate.ToString()
                    });

                    if(insertData > 0)
                    {
                        return "SUCCESS";
                    }
                    else
                    {
                        return "Failed to update";
                    }
                }
                


            }catch(Exception ex)
            {
                return $"Error: {ex.Message}";
            }
        }



    }
}
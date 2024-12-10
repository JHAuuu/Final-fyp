using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace fyp
{
    public partial class LoanHistory : System.Web.UI.Page
    {
        static int userid = 0;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Session["PatronId"] != null)
                {
                    userid = Convert.ToInt32(Session["PatronId"].ToString());

                    DataTable getLoan = getAllLoan();
                    if (getLoan.Rows.Count > 0)
                    {
                        rptLoan.DataSource = getLoan;
                        rptLoan.DataBind();
                    }
                   
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
    Loan.LatestReturn,
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
    AND Loan.Status = 'returned'
AND Loan.LatestReturn IS NOT NULL";
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
                dt.Columns.Add("LatestReturn", typeof(string));
                dt.Columns.Add("ISBN", typeof(string));
                dt.Columns.Add("BookId", typeof(string));
                dt.Columns.Add("BookCopyImage", typeof(string));
                dt.Columns.Add("BookTitle", typeof(string));
                dt.Columns.Add("BookDesc", typeof(string));

                if (originalDt.Rows.Count > 0)
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
                                else if (column.ColumnName == "StartDate" || column.ColumnName == "EndDate" || column.ColumnName == "LatestReturn")
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




            }
            catch (Exception ex)
            {
                loanEmptyMessage.Visible = true;
                return new DataTable();
            }
        }

    }
}
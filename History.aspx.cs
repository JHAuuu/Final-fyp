using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace fyp
{
    public partial class History : System.Web.UI.Page
    {
        static int userid = 0;
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Session["PatronId"] != null)
                {
                    userid = Convert.ToInt32(Session["PatronId"].ToString());

                    DataTable dt = getHistory();
                    if (dt.Rows.Count > 0)
                    {
                        rptHistory.DataSource = getHistory();
                        rptHistory.DataBind();
                        pnlNoHistory.Visible = false;
                    }
                    else
                    {
                        rptHistory.DataSource = null;
                        rptHistory.DataBind();
                        pnlNoHistory.Visible = true;
                    }

                }
                else
                {
                    Response.Redirect("Home.aspx");
                }
            }

               
        }


        public DataTable getHistory()
        {
            try
            {
                string query = @"SELECT 
    h.HistoryDate,
    b.BookId,
    b.BookTitle,
    b.BookDesc,
    b.BookSeries,
    b.BookImage,
   (SELECT STRING_AGG(a.AuthorName, ', ') 
     FROM BookAuthor ba
     INNER JOIN Author a ON ba.AuthorId = a.AuthorId
     WHERE ba.BookId = b.BookId) AS Authors,
    -- Fetch categories as a comma-separated string
    (SELECT STRING_AGG(c.CategoryName, ', ') 
     FROM BookCategory bc
     INNER JOIN Category c ON bc.CategoryId = c.CategoryId
     WHERE bc.BookId = b.BookId) AS Categories
FROM 
    History h
INNER JOIN 
    Book b ON h.BookId = b.BookId
WHERE PatronId = @userId
ORDER BY 
    h.HistoryDate DESC;
";

                DataTable originalDt = DBHelper.ExecuteQuery(query, new string[]{
                    "userId", userid.ToString()
                });

                DataTable dt = new DataTable();
                dt.Columns.Add("HistoryDate", typeof(string));
                dt.Columns.Add("BookId", typeof(string));
                dt.Columns.Add("BookTitle", typeof(string));
                dt.Columns.Add("BookDesc", typeof(string));
                dt.Columns.Add("BookSeries", typeof(string));
                dt.Columns.Add("BookImage", typeof(string));
                dt.Columns.Add("Authors", typeof(string));
                dt.Columns.Add("Categories", typeof(string));

                if (originalDt.Rows.Count > 0)
                {
                    foreach (DataRow originalRow in originalDt.Rows)
                    {
                        DataRow newRow = dt.NewRow();
                        foreach (DataColumn column in originalDt.Columns)
                        {


                            if (originalRow[column] != DBNull.Value)
                            {
                                if (column.ColumnName == "BookImage")
                                {

                                    newRow[column.ColumnName] = ImageHandler.GetImage((byte[])originalRow[column]);
                                }
                                else if(column.ColumnName == "HistoryDate")
                                {
                                    newRow[column.ColumnName] = DateTime.Parse(originalRow[column].ToString()).ToString("yyyy-MM-dd");
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

        [System.Web.Services.WebMethod(Description = "Delete History")]
        public static string DeleteHistory(int bookId)
        {
            try
            {

                // Query to delete the history record
                string query = @"
            DELETE FROM History
            WHERE PatronId = @patronId AND BookId = @bookId";

                int rowsAffected = DBHelper.ExecuteNonQuery(query, new string[]
                {
            "patronId", userid.ToString(),
            "bookId", bookId.ToString()
                });

                if (rowsAffected > 0)
                {
                    return "SUCCESS";
                }
                else
                {
                    return "No record found to delete.";
                }
            }
            catch (Exception ex)
            {
                return $"Error: {ex.Message}";
            }
        }

        protected void btnClearAll_Click(object sender, EventArgs e)
        {
            try
            {

                // Query to delete all history records for the current patron
                string query = "DELETE FROM History WHERE PatronId = @patronId";

                int rowsAffected = DBHelper.ExecuteNonQuery(query, new string[]
                {
            "patronId", userid.ToString()
                });
                rptHistory.DataSource = null;
                rptHistory.DataBind();
                pnlNoHistory.Visible = true;
            }
            catch (Exception ex)
            {
                // Handle exceptions
                ClientScript.RegisterStartupScript(this.GetType(), "alert",
                    $"Swal.fire('Error', 'An error occurred: {ex.Message}', 'error');", true);
            }
        }

    }
}
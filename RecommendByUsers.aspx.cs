using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace fyp
{
    public partial class RecommendByUsers : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                DataTable BooksDt = getPreferencesList();


                if (BooksDt.Rows.Count > 0)
                {
                    rptBooks.DataSource = BooksDt;
                    rptBooks.DataBind();
                }
            }
        }


        public DataTable getPreferencesList()
        {
            try
            {
                string query = @"SELECT 
    B.BookId,
    B.BookTitle,
    B.BookDesc,
    B.BookSeries,
    B.BookImage,
     (SELECT STRING_AGG(c.CategoryName, ', ') 
     FROM BookCategory bcg 
     JOIN Category c ON bcg.CategoryId = c.CategoryId 
     WHERE bcg.BookId = b.BookId) AS CategoryNames,  
      (SELECT STRING_AGG(a.AuthorName, ', ') 
         FROM BookAuthor ba 
         JOIN Author a ON ba.AuthorId = a.AuthorId 
         WHERE ba.BookId = b.BookId) AS AuthorNames,
    SUM(CASE WHEN L.Recommended = 1 THEN 1 ELSE 0 END) AS RecommendedCount,
    SUM(CASE WHEN L.Recommended = 0 THEN 1 ELSE 0 END) AS NotRecommendedCount
FROM 
    Book B
LEFT JOIN 
    BookCopy BC ON B.BookId = BC.BookId
LEFT JOIN 
    Loan L ON BC.BookCopyId = L.BookCopyId
WHERE 
    B.IsDeleted = 0
GROUP BY 
    B.BookId, B.BookTitle, B.BookDesc, B.BookSeries, B.BookImage
HAVING 
    ABS(SUM(CASE WHEN L.Recommended = 1 THEN 1 ELSE 0 END) - 
        SUM(CASE WHEN L.Recommended = 0 THEN 1 ELSE 0 END)) <= 1
ORDER BY 
    BookId;         
                                    ";


                DataTable originalDt = DBHelper.ExecuteQuery(query, new string[]{
                });

                DataTable dt = new DataTable();
                dt.Columns.Add("BookID", typeof(string));
                dt.Columns.Add("BookTitle", typeof(string));
                dt.Columns.Add("BookDesc", typeof(string));
                dt.Columns.Add("BookSeries", typeof(string));
                dt.Columns.Add("BookImage", typeof(string));
                dt.Columns.Add("CategoryNames", typeof(string));
                dt.Columns.Add("AuthorNames", typeof(string));
                dt.Columns.Add("RecommendedCount", typeof(string));
                dt.Columns.Add("NotRecommendedCount", typeof(string));


                foreach (DataRow originalRow in originalDt.Rows)
                {
                    DataRow newRow = dt.NewRow();
                    foreach (DataColumn column in originalDt.Columns)
                    {
                        if (column.ColumnName == "BookImage" && originalRow[column] != DBNull.Value)
                        {

                            newRow[column.ColumnName] = ImageHandler.GetImage((byte[])originalRow[column]);
                        }
                        else if (column.ColumnName != "BookImage" && originalRow[column] != DBNull.Value)
                        {
                            newRow[column.ColumnName] = originalRow[column].ToString();
                        }
                        else
                        {
                            newRow[column.ColumnName] = DBNull.Value;
                        }

                    }
                    dt.Rows.Add(newRow);
                }
                return dt;
            }catch(Exception ex)
            {
                return new DataTable();
            }
            
        }


        protected void rptBooks_PreRender(object sender, EventArgs e)
        {
            // Check if the repeater has data
            bool hasData = rptBooks.Items.Count > 0;

            // Show or hide the empty message based on the data count
            emptyMessage.Visible = !hasData;
            pnlBooks.Visible = hasData;
        }
    }
}
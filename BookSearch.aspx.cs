using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace fyp
{
    public partial class BookSearch : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
          
               
                    DataTable BooksDt = getSearchBook();


                    if (BooksDt.Rows.Count > 0)
                    {
                        rptBooks.DataSource = BooksDt;
                        rptBooks.DataBind();
                    }
                
                
                
            

        }

        public DataTable getSearchBook()
        {
            try
            {

                string searchInput = tbSearch.Text.ToString();
                string query = @"WITH BookDetails AS (
    SELECT 
        b.BookId, 
        b.BookTitle, 
        b.BookDesc, 
        b.BookSeries, 
        b.BookImage,
        -- Aggregate Category Names
        (SELECT STRING_AGG(c.CategoryName, ', ') 
         FROM BookCategory bcg 
         JOIN Category c ON bcg.CategoryId = c.CategoryId 
         WHERE bcg.BookId = b.BookId) AS CategoryNames,
        -- Aggregate Author Names
        (SELECT STRING_AGG(a.AuthorName, ', ') 
         FROM BookAuthor ba 
         JOIN Author a ON ba.AuthorId = a.AuthorId 
         WHERE ba.BookId = b.BookId) AS AuthorNames
    FROM 
        Book AS b
    WHERE
            B.IsDeleted = 0
)
SELECT 
    BookId, 
    BookTitle, 
    BookDesc, 
    BookSeries, 
    BookImage, 
    CategoryNames
FROM 
    BookDetails

ORDER BY 
    CASE 
        WHEN BookTitle LIKE '%' + @searchTerm + '%' 
            OR BookDesc LIKE '%' + @searchTerm + '%' 
            OR AuthorNames LIKE '%' + @searchTerm + '%' 
            OR CategoryNames LIKE '%' + @searchTerm + '%' 
        THEN 1 
        ELSE 2 
    END, 
    BookId DESC;
";


                DataTable originalDt = DBHelper.ExecuteQuery(query, new string[]{
                    "searchTerm", searchInput
                });

                DataTable dt = new DataTable();
                dt.Columns.Add("BookID", typeof(string));
                dt.Columns.Add("BookTitle", typeof(string));
                dt.Columns.Add("BookDesc", typeof(string));
                dt.Columns.Add("BookSeries", typeof(string));
                dt.Columns.Add("BookImage", typeof(string));
                dt.Columns.Add("CategoryNames", typeof(string));



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
                if (dt.Rows.Count > 0)
                {
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


        public DataTable getAllBooks()
        {
            try
            {
                string query = @"SELECT b.BookId
      ,b.BookTitle
      ,b.BookDesc
      ,b.BookSeries
      ,b.BookImage
,(SELECT STRING_AGG(c.CategoryName, ', ') 
     FROM BookCategory bcg 
     JOIN Category c ON bcg.CategoryId = c.CategoryId 
     WHERE bcg.BookId = b.BookId) AS CategoryNames
  FROM Book b
WHERE     b.IsDeleted = 0
JOIN BookCategory bcg  ON b.BookId = bcg.BookId 
JOIN Category c ON bcg.CategoryId = c.CategoryId 
  ORDER BY BookId DESC;";


                DataTable originalDt = DBHelper.ExecuteQuery(query);

                DataTable dt = new DataTable();
                dt.Columns.Add("BookID", typeof(string));
                dt.Columns.Add("BookTitle", typeof(string));
                dt.Columns.Add("BookDesc", typeof(string));
                dt.Columns.Add("BookSeries", typeof(string));
                dt.Columns.Add("BookImage", typeof(string));
                dt.Columns.Add("CategoryNames", typeof(string));



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
                if(dt.Rows.Count > 0)
                {
                    return dt;
                }
                else
                {
                    return new DataTable();
                }
               
            }
            catch(Exception ex)
            { 
                return new DataTable();
            }
        }

        private DataTable GetAuthorsForBook(string bookId)
        {
            string authorQuery = @"SELECT a.AuthorName FROM Author AS a
                           INNER JOIN BookAuthor AS ba ON a.AuthorId = ba.AuthorId
                           WHERE ba.BookId = @bookId";
            DataTable originalDt = DBHelper.ExecuteQuery(authorQuery, new string[] { "@bookId", bookId });
            DataTable dt = new DataTable();
            dt.Columns.Add("AuthorName", typeof(string));
            for (int i = 0; i < originalDt.Rows.Count; i++)
            {
                DataRow row = originalDt.Rows[i];
                // Check for DBNull and add the author name to the new DataTable
                if (row["AuthorName"] != DBNull.Value)
                {
                    DataRow newRow = dt.NewRow();
                    string authorName = row["AuthorName"].ToString();
                    newRow["AuthorName"] = authorName + (i < originalDt.Rows.Count - 1 ? "," : "");
                    dt.Rows.Add(newRow);
                }
            }
            return dt;
        }
        protected void rptBooks_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                // Get the current book's data
                DataRowView rowView = (DataRowView)e.Item.DataItem;
                string bookId = rowView["BookID"].ToString();

                // Find the nested Repeater control for authors
                Repeater rptAuthors = (Repeater)e.Item.FindControl("rptAuthors");

                // Query authors for the current book
                DataTable authorsDataTable = GetAuthorsForBook(bookId); // Fetch authors for this book
                rptAuthors.DataSource = authorsDataTable;
                rptAuthors.DataBind();
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
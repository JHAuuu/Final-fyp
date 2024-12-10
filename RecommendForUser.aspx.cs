using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace fyp
{
    public partial class RecommendForUser : System.Web.UI.Page
    {
        static int userid = 0;
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Session["PatronId"] != null)
                {
                    userid = Convert.ToInt32(Session["PatronId"].ToString());
                    DataTable BooksDt = getPreferencesList();


                    if (BooksDt.Rows.Count > 0)
                    {
                        rptBooks.DataSource = BooksDt;
                        rptBooks.DataBind();
                    }
                }
            }
        }

        public DataTable getPreferencesList()
        {
            try
            {
                string query = @"WITH BookDetails AS (
    SELECT 
        B.BookId,
        B.BookTitle,
        B.BookDesc,
        B.BookSeries,
        B.BookImage,
        (SELECT STRING_AGG(C.CategoryName, ', ') 
         FROM BookCategory BC 
         JOIN Category C ON BC.CategoryId = C.CategoryId 
         WHERE BC.BookId = B.BookId) AS CategoryNames,  
        (SELECT STRING_AGG(A.AuthorName, ', ') 
         FROM BookAuthor BA 
         JOIN Author A ON BA.AuthorId = A.AuthorId 
         WHERE BA.BookId = B.BookId) AS AuthorNames
    FROM 
        Book B
    WHERE
        B.IsDeleted = 0
),
SimilarBooks AS (
    SELECT 
        BD.BookId,
        BD.BookTitle,
        BD.BookDesc,
        BD.BookSeries,
        BD.BookImage,
        BD.CategoryNames,
        BD.AuthorNames,
        (SELECT STRING_AGG(F.BookId, ', ') 
         FROM Favourite F
         WHERE F.PatronId = @PatronId
           AND (
               EXISTS (SELECT 1 
                       FROM BookCategory BC 
                       WHERE BC.BookId = F.BookId 
                         AND BC.CategoryId IN (
                             SELECT BC2.CategoryId 
                             FROM BookCategory BC2 
                             WHERE BC2.BookId = BD.BookId
                         )) 
               OR EXISTS (SELECT 1 
                          FROM BookAuthor BA 
                          WHERE BA.BookId = F.BookId 
                            AND BA.AuthorId IN (
                                SELECT BA2.AuthorId 
                                FROM BookAuthor BA2 
                                WHERE BA2.BookId = BD.BookId
                            ))
           )
        ) AS SimilarBookIds
    FROM 
        BookDetails BD
    WHERE 
        BD.BookId NOT IN (SELECT BookId FROM Favourite WHERE PatronId = @PatronId) -- Exclude user's favorites
)
SELECT 
    SB.BookId,
    SB.BookTitle,
    SB.BookDesc,
    SB.BookSeries,
    SB.BookImage,
    SB.CategoryNames,
    SB.AuthorNames,
    (SELECT STRING_AGG(BookTitle, ', ')
     FROM Book 
     WHERE BookId IN (SELECT value FROM STRING_SPLIT(SB.SimilarBookIds, ','))
    ) AS SimilarTo
FROM 
    SimilarBooks SB
WHERE 
    SB.SimilarBookIds IS NOT NULL -- Exclude rows without any similar books
ORDER BY 
    SB.BookTitle;

      ";


                DataTable originalDt = DBHelper.ExecuteQuery(query, new string[]{
                    "PatronId", userid.ToString()
                });

                DataTable dt = new DataTable();
                dt.Columns.Add("BookID", typeof(string));
                dt.Columns.Add("BookTitle", typeof(string));
                dt.Columns.Add("BookDesc", typeof(string));
                dt.Columns.Add("BookSeries", typeof(string));
                dt.Columns.Add("BookImage", typeof(string));
                dt.Columns.Add("CategoryNames", typeof(string));
                dt.Columns.Add("AuthorNames", typeof(string));
                dt.Columns.Add("SimilarTo", typeof(string));



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
            }
            catch (Exception ex)
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
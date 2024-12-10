using System;
using fyp.Authentication;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using System.Web.Services;

namespace fyp
{
    public partial class BookManagement : AdminPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {

            var master = this.Master as DashMasterPage;
            if (master != null)
            {
                master.titleText = "Book Management";
            }

            // This binds the DropDownList, make sure SqlDataSourceCategory is set correctly.
            

            if (!IsPostBack)
            {
                BooksRepeater.DataBind();
                // Bind data for the CheckBoxList
                cblCategoryIds.DataBind();
                cblAuthors.DataBind();
                LoadDraftBooks();
            }
        }

        protected void btnView_Click(object sender, EventArgs e)
        {
            // Get the button that was clicked  
            Button btnView = (Button)sender;

            // Retrieve the CommandArgument which contains the BookId  
            string bookId = btnView.CommandArgument;

            // Store BookId in session  
            Session["BookId"] = bookId;

            // Redirect to BookCopyManagement.aspx  
            Response.Redirect("~/BookCopyManagement.aspx");
        }


        protected void btnSubmitBook_Click(object sender, EventArgs e)
        {
            string bookTitle = txtBookTitle.Text;
            string bookDescription = txtBookDesc.Text;
            string bookSeries = txtBookSeries.Text;

            try
            {
                // Check if the book title already exists
                string checkQuery = "SELECT BookTitle FROM Book WHERE BookTitle = @BookTitle";
                object[] checkParams = { "@BookTitle", txtBookTitle.Text };

                DataTable resultTable = fyp.DBHelper.ExecuteQuery(checkQuery, checkParams);

                if (resultTable.Rows.Count > 0)
                {
                    string script = "alert('The book \"" + txtBookTitle.Text + "\" already exists.');";
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "BookExistsAlert", script, true);
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "OpenAddBookModal", "showAddBookModal();", true);
                    return;
                }
                else
                {
                    // Optional: Update the book image if a new file is uploaded
                    byte[] bookImage = null;
                    bool hasImage = fileUploadBookImage.HasFile;

                    if (hasImage)
                    {
                        using (System.IO.Stream fs = fileUploadBookImage.PostedFile.InputStream)
                        using (System.IO.BinaryReader br = new System.IO.BinaryReader(fs))
                        {
                            bookImage = br.ReadBytes((int)fs.Length);
                        }
                    }

                    // Prepare the SQL query and parameters based on whether there's an image
                    string insertBookQuery;
                    object[] insertBookParams;

                    if (hasImage)
                    {
                        insertBookQuery = "INSERT INTO Book (BookTitle, BookDesc, BookSeries, BookImage) OUTPUT INSERTED.BookId VALUES (@BookTitle, @BookDesc, @BookSeries, @BookImage)";
                        insertBookParams = new object[] {
                    "@BookTitle", bookTitle,
                    "@BookDesc", bookDescription,
                    "@BookSeries", bookSeries,
                    "@BookImage", bookImage
                };
                    }
                    else
                    {
                        insertBookQuery = "INSERT INTO Book (BookTitle, BookDesc, BookSeries) OUTPUT INSERTED.BookId VALUES (@BookTitle, @BookDesc, @BookSeries)";
                        insertBookParams = new object[] {
                    "@BookTitle", bookTitle,
                    "@BookDesc", bookDescription,
                    "@BookSeries", bookSeries
                };
                    }

                    // Execute the query to insert the new book and get the new BookId
                    int newBookId = (int)fyp.DBHelper.ExecuteScalar(insertBookQuery, insertBookParams);

                    // Link selected categories to the new book
                    foreach (ListItem item in cblCategoryIds.Items)
                    {
                        if (item.Selected)
                        {
                            int categoryId = Convert.ToInt32(item.Value);
                            string insertCategoryQuery = "INSERT INTO BookCategory (BookId, CategoryId) VALUES (@BookId, @CategoryId)";
                            object[] categoryParams = { "@BookId", newBookId, "@CategoryId", categoryId };
                            fyp.DBHelper.ExecuteNonQuery(insertCategoryQuery, categoryParams);
                        }
                    }

                    foreach (ListItem item in cblAuthors.Items)
                    {
                        if (item.Selected)
                        {
                            int authorId = Convert.ToInt32(item.Value);
                            string insertAuthorQuery = "INSERT INTO BookAuthor (BookId, AuthorId) VALUES (@BookId, @AuthorId)";
                            object[] authorParams = { "@BookId", newBookId, "@AuthorId", authorId };
                            fyp.DBHelper.ExecuteNonQuery(insertAuthorQuery, authorParams);
                        }
                    }

                    // Refresh the book list and show a success alert
                    BooksRepeater.DataBind();
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "SuccessAlert", "alert('Book inserted successfully!');", true);
                    ClearFormFields();
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "CloseAddBookModal", "hideAddBookModal();", true);
                }
            }
            catch (Exception ex)
            {
                string errorMessage = $"An error occurred: {ex.Message}";
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ErrorAlert", $"alert('{errorMessage}');", true);
                ClearFormFields();
            }


        }

        private void ClearFormFields()
        {
            txtBookTitle.Text = string.Empty;
            txtBookDesc.Text = string.Empty;
            txtBookSeries.Text = string.Empty;

            // Clear checkbox lists
            foreach (ListItem item in cblCategoryIds.Items)
            {
                item.Selected = false;
            }

            foreach (ListItem item in cblAuthors.Items)
            {
                item.Selected = false;
            }

            // Clear file upload control
            fileUploadBookImage.Attributes.Clear();
        }

        // Define response class to structure response from InsertBook
        public class InsertBookResponse
        {
            public bool success { get; set; }  // Change to lowercase 's'
            public string message { get; set; } // Change to lowercase 'm'
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            string searchText = searchBar.Text.Trim();

            if (!string.IsNullOrEmpty(searchText))
            {
                // Update SelectCommand to filter based on BookTitle or BookDesc
                SqlDataSource1.SelectCommand = "SELECT BookId, BookTitle, BookDesc, BookSeries, BookImage FROM Book " +
                                               "WHERE IsDeleted = 0 AND (BookTitle LIKE '%' + @SearchText + '%' OR BookDesc LIKE '%' + @SearchText + '%')";
                SqlDataSource1.SelectParameters.Clear();
                SqlDataSource1.SelectParameters.Add("SearchText", searchText);
            }
            else
            {
                // Reset to show all books if search text is empty
                SqlDataSource1.SelectCommand = "SELECT BookId, BookTitle, BookDesc, BookSeries, BookImage FROM Book WHERE IsDeleted = 0";
            }

            // Rebind the Repeater to apply the updated filter
            BooksRepeater.DataBind();
        }

        protected void btnAddAuthor_Click(object sender, EventArgs e)
        {
            string newAuthorName = txtNewAuthor.Text.Trim();

            // If the new author input is not empty, insert it into the Author table
            if (!string.IsNullOrEmpty(newAuthorName))
            {
                string query = "INSERT INTO Author (AuthorName) VALUES (@AuthorName)";

                object[] checkParams = { "@AuthorName", newAuthorName };

                int resultTable = DBHelper.ExecuteNonQuery(query, checkParams);

                txtNewAuthor.Text = string.Empty;
                hfModalState.Value = "true";

                cblAuthors.DataBind();
            }
            else
            {
                // Display an error if no author name is entered
                lblErrorMessage.Text = "Please enter a valid author name.";
            }
        }

        protected void btnAddCategory_Click(object sender, EventArgs e)
        {
            string newCategoryName = txtNewCategory.Text.Trim();

            // If the new author input is not empty, insert it into the Author table
            if (!string.IsNullOrEmpty(newCategoryName))
            {
                string insertCategoryQuery = "INSERT INTO Category (CategoryName) VALUES (@CategoryName)";

                object[] checkParams = { "@CategoryName", newCategoryName };

                int resultTable = DBHelper.ExecuteNonQuery(insertCategoryQuery, checkParams);

                // Clear the textbox and refresh the dropdown
                txtNewCategory.Text = string.Empty;
                hfModalState.Value = "true";

                cblCategoryIds.DataBind();
            }
            else
            {
                // Display an error if no author name is entered
                lblErrorMessage.Text = "Please enter a valid author name.";
            }
        }

        private void LoadDraftBooks()
        {
            string query = "SELECT BookId, BookTitle, BookImage FROM Book WHERE IsDeleted = 1";
            DataTable dt = DBHelper.ExecuteQuery(query); // Replace DBHelper with your data access logic
            GridViewDraftBooks.DataSource = dt;
            GridViewDraftBooks.DataBind();
        }

        protected void GridViewDraftBooks_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "RestoreBook")
            {
                // Get the BookId from the CommandArgument
                int bookId = Convert.ToInt32(e.CommandArgument);

                // Step 1: Update the IsDeleted field to 0 (restore the book)
                string restoreBookQuery = "UPDATE Book SET IsDeleted = 0 WHERE BookId = @BookId";
                DBHelper.ExecuteNonQuery(restoreBookQuery, new object[] { "@BookId", bookId });

                // Step 2: Rebind the GridView to reflect the changes
                LoadDraftBooks();

                // Step 3: Show success message via JavaScript alert
                string script = "alert('The book has been successfully restored.');";
                ClientScript.RegisterStartupScript(this.GetType(), "RestoreAlert", script, true);
                BooksRepeater.DataBind();
            }
        }

    }
}
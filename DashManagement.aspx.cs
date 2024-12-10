using System;
using fyp.Authentication;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using System.Web.Security;
using System.Web.Services;

namespace fyp
{
    public partial class DashManagement : AdminPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {

            var master = this.Master as DashMasterPage;
            if (master != null)
            {
                master.titleText = "Dashboard";
            }

            if (!IsPostBack)
            {
                // Retrieve counts for Users, Staff, and Books
                lblUserNum.Text = GetCountFromDatabase("SELECT COUNT(*) AS UserCount FROM [User]").ToString();
                lblStaffNum.Text = GetCountFromDatabase("SELECT COUNT(*) AS StaffCount FROM [User] WHERE UserRole = @UserRole", new object[] { "@UserRole", "Staff" }).ToString();
                lblBookNum.Text = GetCountFromDatabase("SELECT COUNT(*) AS BookCount FROM [Book]").ToString();


                // Get available dates for Book Borrowed and Book Added reports
                List<DateTime> borrowedDates = GetAvailableDates();
                List<DateTime> addedDates = GetAddedDates();

                string borrowedDatesJson = Newtonsoft.Json.JsonConvert.SerializeObject(borrowedDates.Select(d => d.ToString("yyyy-MM-dd")));
                string addedDatesJson = Newtonsoft.Json.JsonConvert.SerializeObject(addedDates.Select(d => d.ToString("yyyy-MM-dd")));

                // Pass the dates to JavaScript
                ClientScript.RegisterStartupScript(
                    this.GetType(),
                    "AvailableDates",
                    $"var borrowedDates = {borrowedDatesJson}; var addedDates = {addedDatesJson};",
                    true
                );
            }


        }

        private int GetCountFromDatabase(string query, object[] parameters = null)
        {
            try
            {
                DataTable resultTable = fyp.DBHelper.ExecuteQuery(query, parameters);
                if (resultTable.Rows.Count > 0)
                {
                    return Convert.ToInt32(resultTable.Rows[0][0]);
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error retrieving count from database: {ex.Message}");
            }

            return 0; // Default to 0 if query fails
        }

        private List<DateTime> GetAvailableDates()
        {
            List<DateTime> availableDates = new List<DateTime>();
            string query = @"
            SELECT DISTINCT CAST(StartDate AS DATE) AS AvailableDate
            FROM Loan
            ORDER BY AvailableDate";

            DataTable dt = fyp.DBHelper.ExecuteQuery(query);

            foreach (DataRow row in dt.Rows)
            {
                availableDates.Add(Convert.ToDateTime(row["AvailableDate"]));
            }

            return availableDates;
        }

        private List<DateTime> GetAddedDates()
        {
            List<DateTime> addedDates = new List<DateTime>();
            string query = @"
        SELECT DISTINCT CAST(Book.CreatedAt AS DATE) AS AvailableDate
        FROM Book
        WHERE Book.IsDeleted = 0
        ORDER BY AvailableDate";

            DataTable dt = fyp.DBHelper.ExecuteQuery(query);
            foreach (DataRow row in dt.Rows)
            {
                addedDates.Add(Convert.ToDateTime(row["AvailableDate"]));
            }
            return addedDates;
        }

        protected void btnViewBorrow_Click(object sender, EventArgs e)
        {
            DateTime startDate;
            DateTime? endDate = null;

            try
            {
                // Try parsing the input values into DateTime objects
                // Parse the start date
                if (!DateTime.TryParse(txtStartDate.Text, out startDate))
                {
                    throw new Exception("Please select a valid start date.");
                }
                // Try parsing the end date (optional)
                if (!string.IsNullOrWhiteSpace(txtEndDate.Text))
                {
                    if (!DateTime.TryParse(txtEndDate.Text, out DateTime parsedEndDate))
                    {
                        throw new Exception("Invalid end date format.");
                    }
                    endDate = parsedEndDate;
                }
                else
                {
                    endDate = startDate; // If the end date is not selected, default to the start date
                }

                // Assuming 'reportData' is a collection of loan report data
                var reportData = GetLoanReports(startDate, endDate.Value); // This should be your method to fetch the report data

                // Generate the PDF report (you can replace this with your method if needed)
                byte[] reportBytes = PdfUtility.GenerateLoanPdfReport("Loan Report", reportData, startDate, endDate.Value);

                // Send the PDF to the browser to display or download
                Response.Clear();
                Response.ContentType = "application/pdf";
                Response.AddHeader("Content-Disposition", "inline; filename=LoanReport.pdf"); // 'inline' will display in the browser
                Response.BinaryWrite(reportBytes);
                Response.Flush(); // Flushes the data to the client
                                  // Response.End() is not required, just return
                return; // Return from the method instead of calling Response.End()

            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error: " + ex.Message);
                // Handle other exceptions
                ScriptManager.RegisterStartupScript(this, this.GetType(), "GenericError", "alert('An error occurred while generating the report. Please try again later.');", true);
            }
        }

        protected void btnGenerateReport_Click(object sender, EventArgs e)
        {
            DateTime startDate;
            DateTime? endDate = null;

            try
            {
                // Try parsing the input values into DateTime objects
                // Parse the start date
                if (!DateTime.TryParse(txtStartDate.Text, out startDate))
                {
                    throw new Exception("Please select a valid start date.");
                }
                // Try parsing the end date (optional)
                if (!string.IsNullOrWhiteSpace(txtEndDate.Text))
                {
                    if (!DateTime.TryParse(txtEndDate.Text, out DateTime parsedEndDate))
                    {
                        throw new Exception("Invalid end date format.");
                    }
                    endDate = parsedEndDate;
                }
                else
                {
                    endDate = startDate; // If the end date is not selected, default to the start date
                }

                // Retrieve the loan report data
                var loanReports = GetLoanReports(startDate, endDate.Value);

                // Generate the PDF report using the retrieved data
                byte[] pdfBytes = PdfUtility.GenerateLoanPdfReport("Loan Report", loanReports, startDate, endDate.Value);

                // Generate the filename with the title and current date
                string currentDate = DateTime.Now.ToString("yyyyMMdd"); // Format: YYYYMMDD
                string filename = $"Book_Addition_Report_{currentDate}.pdf";

                // Send the PDF to the browser for download
                Response.Clear();
                Response.ContentType = "application/pdf";
                Response.AddHeader("Content-Disposition", $"attachment; filename={filename}"); // 'inline' will display in the browser
                Response.BinaryWrite(pdfBytes);
                Response.Flush(); // Flushes the data to the client
                                  // Response.End() is not required, just return
                return; // Return from the method instead of calling Response.End()
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error: " + ex.Message);
                // Handle other exceptions
                ScriptManager.RegisterStartupScript(this, this.GetType(), "GenericError", "alert('An error occurred while generating the report. Please try again later.');", true);
            }
        }

        private List<LoanReport> GetLoanReports(DateTime startDate, DateTime endDate)
        {
            List<LoanReport> loanReports = new List<LoanReport>();

            string query = @"
    SELECT 
        Loan.LoanId,
        Loan.StartDate,
        Loan.EndDate,
        BookCopy.BookCopyId,
        Book.BookTitle,
        STRING_AGG(Category.CategoryName, ', ') AS CategoryNames, -- Aggregate categories
        [User].UserName,
        Loan.LatestReturn,  -- Use LatestReturn from Loan table instead of Punishment
        BookCopy.BookCopyImage,  -- Fetch BookCopyImage from BookCopy table
        BookCopy.ISBN  -- Fetch ISBN from BookCopy table
    FROM 
        Loan
    INNER JOIN 
        BookCopy ON Loan.BookCopyId = BookCopy.BookCopyId
    INNER JOIN 
        Book ON BookCopy.BookId = Book.BookId
    LEFT JOIN 
        BookCategory ON Book.BookId = BookCategory.BookId
    LEFT JOIN 
        Category ON BookCategory.CategoryId = Category.CategoryId
    INNER JOIN 
        Patron ON Loan.PatronId = Patron.PatronId
    INNER JOIN 
        [User] ON Patron.UserId = [User].UserId
    LEFT JOIN 
        Punishment ON Loan.LoanId = Punishment.LoanId
    WHERE 
        Loan.StartDate >= @StartDate AND Loan.StartDate <= @EndDate
    GROUP BY 
        Loan.LoanId, Loan.StartDate, Loan.EndDate, BookCopy.BookCopyId, Book.BookTitle, 
        [User].UserName, Loan.LatestReturn, BookCopy.BookCopyImage, BookCopy.ISBN
    ORDER BY 
        Loan.StartDate;";

            object[] arrFindBorrowBook = new object[4];
            arrFindBorrowBook[0] = "@StartDate";
            arrFindBorrowBook[1] = startDate;
            arrFindBorrowBook[2] = "@EndDate";
            arrFindBorrowBook[3] = endDate;
            DataTable dt = fyp.DBHelper.ExecuteQuery(query, arrFindBorrowBook);

            // Iterate through each row in the DataTable and populate the loanReports list
            foreach (DataRow row in dt.Rows)
            {
                LoanReport loanReport = new LoanReport
                {
                    LoanId = Convert.ToInt32(row["LoanId"]),
                    StartDate = Convert.ToDateTime(row["StartDate"]),
                    EndDate = Convert.ToDateTime(row["EndDate"]),
                    BookCopyId = Convert.ToInt32(row["BookCopyId"]),
                    BookTitle = row["BookTitle"].ToString(),
                    CategoryNames = row["CategoryNames"] != DBNull.Value ? row["CategoryNames"].ToString() : "N/A",
                    UserName = row["UserName"].ToString(),
                    LatestReturn = row["LatestReturn"] != DBNull.Value ? Convert.ToDateTime(row["LatestReturn"]) : (DateTime?)null,
                    BookCopyImage = row["BookCopyImage"] != DBNull.Value ? (byte[])row["BookCopyImage"] : null,  // Handle the byte array for the image
                    ISBN = row["ISBN"].ToString()
                };

                loanReports.Add(loanReport);
            }

            return loanReports;
        }

        protected void btnViewAddBook_Click(object sender, EventArgs e)
        {
            DateTime startDate;
            DateTime? endDate = null;

            try
            {
                // Parse the start date
                if (!DateTime.TryParse(txtBookStartDate.Text, out startDate))
                {
                    throw new Exception("Please select a valid start date.");
                }

                // Try parsing the end date (optional)
                if (!string.IsNullOrWhiteSpace(txtBookEndDate.Text))
                {
                    if (!DateTime.TryParse(txtBookEndDate.Text, out DateTime parsedEndDate))
                    {
                        throw new Exception("Invalid end date format.");
                    }
                    endDate = parsedEndDate;
                }
                else
                {
                    endDate = startDate; // If the end date is not selected, default to the start date
                }

                // Assuming 'reportData' is a collection of loan report data
                var reportData = GetAddBookReports(startDate, endDate.Value); // This should be your method to fetch the report data

                // Generate the PDF report (you can replace this with your method if needed)
                byte[] reportBytes = PdfUtility.GenerateBookPdfReport("Book Addition Report", reportData, startDate, endDate.Value);

                // Generate the filename with the title and current date
                string currentDate = DateTime.Now.ToString("yyyyMMdd"); // Format: YYYYMMDD
                string filename = $"Book_Addition_Report_{currentDate}.pdf";

                // Send the PDF to the browser to display or download
                Response.Clear();
                Response.ContentType = "application/pdf";
                Response.AddHeader("Content-Disposition", $"inline; filename={filename}"); // 'inline' will display in the browser
                Response.BinaryWrite(reportBytes);
                Response.Flush(); // Flushes the data to the client
                                  // Response.End() is not required, just return
                return; // Return from the method instead of calling Response.End()

            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error: " + ex.Message);
                // Handle other exceptions
                ScriptManager.RegisterStartupScript(this, this.GetType(), "GenericError", "alert('An error occurred while generating the report. Please try again later.');", true);
            }
        }

        private List<BookReport> GetAddBookReports(DateTime startDate, DateTime endDate)
        {
            List<BookReport> bookReports = new List<BookReport>();

            string query = @"
    SELECT 
        Book.BookId,
        Book.BookTitle,
        Book.BookDesc,
        Book.BookSeries,
        Book.CreatedAt,
        STRING_AGG(Category.CategoryName, ', ') AS CategoryNames,  -- Aggregate category names
        STRING_AGG(Author.AuthorName, ', ') AS AuthorNames,        -- Aggregate author names
        BookCopy.ISBN,
        BookCopy.PublishDate,
        BookCopy.PublishOwner,
        BookCopy.IsAvailable,
        BookCopy.CreatedAt AS BookCopyCreatedAt,  -- Add Book Copy Creation Date
        BookCopy.BookCopyImage  -- Fetch BookCopyImage as a byte array
    FROM 
        Book
    LEFT JOIN 
        BookCategory ON Book.BookId = BookCategory.BookId
    LEFT JOIN 
        Category ON BookCategory.CategoryId = Category.CategoryId
    LEFT JOIN 
        BookAuthor ON Book.BookId = BookAuthor.BookId
    LEFT JOIN 
        Author ON BookAuthor.AuthorId = Author.AuthorId
    LEFT JOIN 
        BookCopy ON Book.BookId = BookCopy.BookId
    WHERE 
        Book.CreatedAt >= @StartDate AND Book.CreatedAt <= @EndDate  -- Filter by CreatedAt
        AND Book.IsDeleted = 0  -- Exclude deleted books
        AND BookCopy.IsDeleted = 0  -- Exclude deleted book copies
    GROUP BY 
        Book.BookId, 
        Book.BookTitle, 
        Book.BookDesc, 
        Book.BookSeries, 
        Book.CreatedAt, 
        BookCopy.ISBN, 
        BookCopy.PublishDate, 
        BookCopy.PublishOwner,  -- Add this to the GROUP BY clause
        BookCopy.IsAvailable, 
        BookCopy.CreatedAt, 
        BookCopy.BookCopyImage
    ORDER BY 
        Book.BookId;";


            object[] parameters = {
                    "@StartDate", startDate,   // Pass your start date here
                    "@EndDate", endDate       // Pass your end date here
                };

            DataTable dt = fyp.DBHelper.ExecuteQuery(query, parameters);

            // Iterate through each row in the DataTable and populate the loanReports list
            foreach (DataRow row in dt.Rows)
            {
                BookReport bookReport = new BookReport
                {
                    BookId = Convert.ToInt32(row["BookId"]),
                    BookTitle = row["BookTitle"].ToString(),
                    BookDesc = row["BookDesc"].ToString(),
                    BookSeries = row["BookSeries"].ToString(),
                    CreatedAt = Convert.ToDateTime(row["CreatedAt"]),
                    CategoryNames = row["CategoryNames"] != DBNull.Value ? row["CategoryNames"].ToString() : "N/A",
                    AuthorNames = row["AuthorNames"] != DBNull.Value ? row["AuthorNames"].ToString() : "N/A",
                    ISBN = row["ISBN"] != DBNull.Value ? row["ISBN"].ToString() : "N/A",
                    PublishDate = row["PublishDate"] != DBNull.Value ? Convert.ToDateTime(row["PublishDate"]) : DateTime.MinValue,
                    PublishOwner = row["PublishOwner"].ToString(),
                    IsAvailable = Convert.ToBoolean(row["IsAvailable"]),
                    BookCopyCreatedAt = Convert.ToDateTime(row["BookCopyCreatedAt"])
                };

                bookReports.Add(bookReport);
            }

            return bookReports;
        }

        protected void btnGenerateAddBook_Click(object sender, EventArgs e)
        {
            DateTime startDate;
            DateTime? endDate = null;

            try
            {
                // Parse the start date
                if (!DateTime.TryParse(txtBookStartDate.Text, out startDate))
                {
                    throw new Exception("Please select a valid start date.");
                }

                // Try parsing the end date (optional)
                if (!string.IsNullOrWhiteSpace(txtBookEndDate.Text))
                {
                    if (!DateTime.TryParse(txtBookEndDate.Text, out DateTime parsedEndDate))
                    {
                        throw new Exception("Invalid end date format.");
                    }
                    endDate = parsedEndDate;
                }
                else
                {
                    endDate = startDate; // If the end date is not selected, default to the start date
                }

                // Assuming 'reportData' is a collection of loan report data
                var reportData = GetAddBookReports(startDate, endDate.Value); // This should be your method to fetch the report data

                // Generate the PDF report (you can replace this with your method if needed)
                byte[] reportBytes = PdfUtility.GenerateBookPdfReport("Book Addition Report", reportData, startDate, endDate.Value);

                // Generate the filename with the title and current date
                string currentDate = DateTime.Now.ToString("yyyyMMdd"); // Format: YYYYMMDD
                string filename = $"Book_Addition_Report_{currentDate}.pdf";

                // Send the PDF to the browser for download
                Response.Clear();
                Response.ContentType = "application/pdf";
                Response.AddHeader("Content-Disposition", $"attachment; filename={filename}"); // 'inline' will display in the browser
                Response.BinaryWrite(reportBytes);
                Response.Flush(); // Flushes the data to the client
                                  // Response.End() is not required, just return
                return; // Return from the method instead of calling Response.End()

            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error: " + ex.Message);
                // Handle other exceptions
                ScriptManager.RegisterStartupScript(this, this.GetType(), "GenericError", "alert('An error occurred while generating the report. Please try again later.');", true);
            }
        }




        //define chart data
        [WebMethod]
        public static object GetBooksBorrowedData()
        {
            // Query to get the monthly count of borrowed books
            string query = @"
            SELECT 
        DATENAME(MONTH, StartDate) AS MonthName, 
        MONTH(StartDate) AS MonthNumber,
        COUNT(*) AS BorrowedBooksCount
    FROM Loan
    GROUP BY DATENAME(MONTH, StartDate), MONTH(StartDate)
    ORDER BY MonthNumber";

            DataTable dt = fyp.DBHelper.ExecuteQuery(query);

            // Prepare the data in a format suitable for JavaScript
            var data = new
            {
                months = dt.AsEnumerable().Select(row => row["MonthName"].ToString()).ToList(),
                borrowedBooks = dt.AsEnumerable().Select(row => Convert.ToInt32(row["BorrowedBooksCount"])).ToList()
            };

            return data;
        }

        [WebMethod]
        public static object GetMostBorrowedBooksByCategory()
        {
            string query = @"
        SELECT 
            c.CategoryName,
            COUNT(l.LoanId) AS BorrowedCount
        FROM Loan l
        JOIN BookCopy bc ON l.BookCopyId = bc.BookCopyId
        JOIN Book b ON bc.BookId = b.BookId
        JOIN BookCategory bcg ON b.BookId = bcg.BookId
        JOIN Category c ON bcg.CategoryId = c.CategoryId
        GROUP BY c.CategoryName
        ORDER BY BorrowedCount DESC";

            DataTable dt = fyp.DBHelper.ExecuteQuery(query);

            var data = new
            {
                categories = dt.AsEnumerable().Select(row => row["CategoryName"].ToString()).ToList(),
                counts = dt.AsEnumerable().Select(row => Convert.ToInt32(row["BorrowedCount"])).ToList()
            };

            return data;
        }

        [WebMethod]
        public static object GetUserActivityData()
        {

            string query = @"
        SELECT 
            DATENAME(MONTH, DateCreated) AS MonthName,
            MONTH(DateCreated) AS MonthNumber,
            COUNT(*) AS NewUsers
        FROM Patron
        WHERE DateCreated IS NOT NULL
        GROUP BY DATENAME(MONTH, DateCreated), MONTH(DateCreated)
        ORDER BY MonthNumber";

            DataTable dt = fyp.DBHelper.ExecuteQuery(query);

            // Format the data for the chart
            var data = new
            {
                months = dt.AsEnumerable().Select(row => row["MonthName"].ToString()).ToList(),
                counts = dt.AsEnumerable().Select(row => Convert.ToInt32(row["NewUsers"])).ToList()
            };

            return data;
        }
    }

}
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using iTextSharp.text; // For iTextSharp specific types like Font, Rectangle, Paragraph
using iTextSharp.text.pdf; // For PdfPTable, PdfPCell, etc.
using System.Drawing; // For System.Drawing.Image
using System.IO;      // For MemoryStream

namespace fyp
{
    public class PdfUtility
    {
        public class PageEvents : iTextSharp.text.pdf.PdfPageEventHelper
        {
            public override void OnEndPage(PdfWriter writer, Document document)
            {
                base.OnEndPage(writer, document);

                // Define font for page number
                iTextSharp.text.Font font = iTextSharp.text.FontFactory.GetFont("Arial", 10, iTextSharp.text.Font.NORMAL, BaseColor.BLACK);

                // Get current page number
                int pageNumber = writer.PageNumber;

                // Define the position (bottom-center)
                float x = document.PageSize.GetLeft(0) + (document.PageSize.Width / 2);
                float y = document.PageSize.GetBottom(30); // 30 units from the bottom

                // Create the page number text and add it to the document
                string pageText = $"Page {pageNumber}";
                ColumnText.ShowTextAligned(writer.DirectContent, Element.ALIGN_CENTER, new Phrase(pageText, font), x, y, 0);
            }
        }

        public static byte[] GenerateLoanPdfReport(string title, IEnumerable<LoanReport> reportData, DateTime startDate, DateTime endDate)
        {
            using (MemoryStream memoryStream = new MemoryStream())
            {
                Document document = new Document(PageSize.A4.Rotate(), 50, 50, 25, 25); // Rotate for more columns
                PdfWriter writer = PdfWriter.GetInstance(document, memoryStream);

                // Assign the page event handler to the PdfWriter
                writer.PageEvent = new PageEvents();

                document.Open();

                // Create the title with background and text color
                iTextSharp.text.Font titleFont = iTextSharp.text.FontFactory.GetFont("Arial", 18, iTextSharp.text.Font.BOLD, BaseColor.WHITE); // White text
                Chunk titleChunk = new Chunk(title, titleFont);

                // Set background color for the title
                PdfPCell titleCell = new PdfPCell(new Phrase(titleChunk))
                {
                    BackgroundColor = new BaseColor(0, 61, 142), // RGB value for #003d8e
                    Border = iTextSharp.text.Rectangle.NO_BORDER, // Use iTextSharp's Rectangle
                    HorizontalAlignment = Element.ALIGN_CENTER
                };

                // Add title to the document in a table format (with no borders)
                PdfPTable titleTable = new PdfPTable(1) { WidthPercentage = 100 };
                titleTable.AddCell(titleCell);
                document.Add(titleTable);

                document.Add(new Paragraph(" ")); // Add some space after the title

                // Add date range under the title
                iTextSharp.text.Font dateRangeFont = iTextSharp.text.FontFactory.GetFont("Arial", 12, iTextSharp.text.Font.NORMAL, BaseColor.BLACK); // Date range font
                string dateRangeText = $"Date: {startDate.ToString("d/M/yyyy")} - {endDate.ToString("d/M/yyyy")}";
                Paragraph dateRangeParagraph = new Paragraph(dateRangeText, dateRangeFont)
                {
                    Alignment = Element.ALIGN_CENTER
                };
                document.Add(dateRangeParagraph);

                document.Add(new Paragraph(" ")); // Add some space after the date range

                // Create a dictionary of category percentages
                var categoryPercentages = new Dictionary<string, float>();
                foreach (var item in reportData)
                {
                    foreach (var category in item.CategoryNames.Split(','))
                    {
                        var trimmedCategory = category.Trim(); // Trim spaces if any
                        if (categoryPercentages.ContainsKey(trimmedCategory))
                            categoryPercentages[trimmedCategory]++;
                        else
                            categoryPercentages.Add(trimmedCategory, 1);
                    }
                }

                // Normalize the category counts to percentages
                float totalCategories = categoryPercentages.Values.Sum();
                foreach (var category in categoryPercentages.Keys.ToList())
                {
                    categoryPercentages[category] = (categoryPercentages[category] / totalCategories) * 100;
                }

                // Generate the pie chart image using System.Drawing (with labels for categories)
                System.Drawing.Image chartImage = ChartUtility.GeneratePieChartWithLabels(categoryPercentages);

                // Convert System.Drawing.Image to iTextSharp.text.Image
                using (MemoryStream chartStream = new MemoryStream())
                {
                    chartImage.Save(chartStream, System.Drawing.Imaging.ImageFormat.Png);  // Save the image as PNG

                    byte[] chartBytes = chartStream.ToArray();  // Convert to byte array

                    // Create iTextSharp Image from byte array
                    iTextSharp.text.Image pdfChartImage = iTextSharp.text.Image.GetInstance(chartBytes);
                    pdfChartImage.ScaleToFit(200f, 200f);  // Optionally scale the image
                    pdfChartImage.Alignment = Element.ALIGN_CENTER;
                    document.Add(pdfChartImage);  // Add the chart image to the document
                }

                // Add the text: Percentage of loan book categories under the pie chart
                iTextSharp.text.Font categoryTextFont = iTextSharp.text.FontFactory.GetFont("Arial", 12, iTextSharp.text.Font.NORMAL, BaseColor.BLACK);
                Paragraph categoryTextParagraph = new Paragraph("Percentage of loan book categories", categoryTextFont)
                {
                    Alignment = Element.ALIGN_CENTER
                };
                document.Add(categoryTextParagraph);

                document.Add(new Paragraph(" ")); // Add some space after the text

                foreach (var item in reportData)
                {
                    // Add Book Copy ID and Book Title as a header
                    iTextSharp.text.Font headerFont = iTextSharp.text.FontFactory.GetFont("Arial", 12, iTextSharp.text.Font.BOLD, BaseColor.BLACK);
                    Paragraph bookHeader = new Paragraph($"Book Name: {item.BookTitle}", headerFont)
                    {
                        Alignment = Element.ALIGN_LEFT
                    };
                    document.Add(bookHeader);

                    document.Add(new Paragraph(" ")); // Add some space after the header

                    // Define the table for this record
                    PdfPTable table = new PdfPTable(7) { WidthPercentage = 100 }; // Adjusted to 6 columns
                    table.SetWidths(new float[] { 10f, 20f, 25f, 20f, 20f, 25f, 20f }); // Adjusted column widths

                    iTextSharp.text.Font tableHeaderFont = iTextSharp.text.FontFactory.GetFont("Arial", 12, iTextSharp.text.Font.BOLD, BaseColor.BLACK);
                    PdfPCell headerCell;
                    // Add table headers
                    headerCell = new PdfPCell(new Phrase("User Name", tableHeaderFont)) { Border = iTextSharp.text.Rectangle.NO_BORDER };
                    table.AddCell(headerCell);
                    headerCell = new PdfPCell(new Phrase("Book Image", tableHeaderFont)) { Border = iTextSharp.text.Rectangle.NO_BORDER };
                    table.AddCell(headerCell);
                    headerCell = new PdfPCell(new Phrase("Book Title", tableHeaderFont)) { Border = iTextSharp.text.Rectangle.NO_BORDER };
                    table.AddCell(headerCell);
                    headerCell = new PdfPCell(new Phrase("Categories", tableHeaderFont)) { Border = iTextSharp.text.Rectangle.NO_BORDER };
                    table.AddCell(headerCell);
                    headerCell = new PdfPCell(new Phrase("ISBN", tableHeaderFont)) { Border = iTextSharp.text.Rectangle.NO_BORDER };
                    table.AddCell(headerCell);
                    headerCell = new PdfPCell(new Phrase("Loan Date Start", tableHeaderFont)) { Border = iTextSharp.text.Rectangle.NO_BORDER };
                    table.AddCell(headerCell);
                    headerCell = new PdfPCell(new Phrase("Latest Return", tableHeaderFont)) { Border = iTextSharp.text.Rectangle.NO_BORDER };
                    table.AddCell(headerCell);

                    // Add horizontal line after headers
                    PdfPCell hrCell = new PdfPCell(new Phrase(" ")) // Empty cell
                    {
                        Colspan = 7, // Span across all columns
                        BorderWidthTop = 1f, // Line thickness
                        BorderWidthBottom = 0f, // No bottom border
                        BorderWidthLeft = 0f,
                        BorderWidthRight = 0f,
                        BorderColorTop = BaseColor.GRAY // Line color
                    };
                    table.AddCell(hrCell);

                    // Add data for this record
                    iTextSharp.text.Font cellFont = iTextSharp.text.FontFactory.GetFont("Arial", 10, iTextSharp.text.Font.NORMAL, BaseColor.BLACK);
                    PdfPCell dataCell;

                    dataCell = new PdfPCell(new Phrase(item.UserName, cellFont)) { Border = iTextSharp.text.Rectangle.NO_BORDER };
                    table.AddCell(dataCell);
                    // Add BookCopyImage if it exists
                    if (item.BookCopyImage != null && item.BookCopyImage.Length > 0)
                    {
                        iTextSharp.text.Image bookImage = iTextSharp.text.Image.GetInstance(item.BookCopyImage);
                        bookImage.ScaleToFit(50f, 50f);  // Scale image to fit within 50x50
                        bookImage.Alignment = Element.ALIGN_CENTER;
                        dataCell = new PdfPCell(bookImage) { Border = iTextSharp.text.Rectangle.NO_BORDER };
                        table.AddCell(dataCell);
                    }
                    // Add Book Copy Image if it exists
                    if (item.BookCopyImage != null && item.BookCopyImage.Length > 0)
                    {
                        using (MemoryStream imgStream = new MemoryStream(item.BookCopyImage))
                        {
                            iTextSharp.text.Image bookImage = iTextSharp.text.Image.GetInstance(imgStream);
                            bookImage.ScaleToFit(50f, 50f);  // Scale image to fit the column (adjust size as needed)
                            bookImage.Alignment = Element.ALIGN_CENTER;

                            // Add the image in the new column
                            dataCell = new PdfPCell(bookImage) { Border = iTextSharp.text.Rectangle.NO_BORDER };
                            table.AddCell(dataCell);
                        }
                    }
                    else
                    {
                        // If no image is available, add a default image from the server path
                        string defaultImagePath = "~/images/defaultCoverBook.png"; // Path to the default image

                        // Convert the default image to a byte array
                        string serverPath = HttpContext.Current.Server.MapPath(defaultImagePath);  // Map the relative path to an absolute server path

                        if (File.Exists(serverPath))
                        {
                            // Load the default image
                            iTextSharp.text.Image defaultImage = iTextSharp.text.Image.GetInstance(serverPath);
                            defaultImage.ScaleToFit(50f, 50f);  // Scale image to fit the column
                            defaultImage.Alignment = Element.ALIGN_CENTER;

                            // Add the default image in the new column
                            dataCell = new PdfPCell(defaultImage) { Border = iTextSharp.text.Rectangle.NO_BORDER };
                            table.AddCell(dataCell);
                        }
                        else
                        {
                            // If the default image is not found, show a placeholder text
                            dataCell = new PdfPCell(new Phrase("No Image Available", cellFont)) { Border = iTextSharp.text.Rectangle.NO_BORDER };
                            table.AddCell(dataCell);
                        }
                    }

                    dataCell = new PdfPCell(new Phrase(item.BookTitle, cellFont)) { Border = iTextSharp.text.Rectangle.NO_BORDER };
                    table.AddCell(dataCell);
                    dataCell = new PdfPCell(new Phrase(item.CategoryNames, cellFont)) { Border = iTextSharp.text.Rectangle.NO_BORDER };
                    table.AddCell(dataCell);
                    headerCell = new PdfPCell(new Phrase(item.ISBN, cellFont)) { Border = iTextSharp.text.Rectangle.NO_BORDER };
                    table.AddCell(headerCell);
                    dataCell = new PdfPCell(new Phrase(item.StartDate.ToShortDateString(), cellFont)) { Border = iTextSharp.text.Rectangle.NO_BORDER };
                    table.AddCell(dataCell);
                    dataCell = new PdfPCell(new Phrase(item.LatestReturn.HasValue ? item.LatestReturn.Value.ToShortDateString() : "Haven't Returned", cellFont)) { Border = iTextSharp.text.Rectangle.NO_BORDER };
                    table.AddCell(dataCell);

                    // Add the table to the document
                    document.Add(table);

                    document.Add(new Paragraph(" ")); // Add space after each table
                }

                // Add Total Book Loan count at the bottom of the table
                iTextSharp.text.Font totalFont = iTextSharp.text.FontFactory.GetFont("Arial", 12, iTextSharp.text.Font.BOLD, BaseColor.BLACK);
                float totalLoanCount = reportData.Count();
                Paragraph totalLoanParagraph = new Paragraph($"Total Book Loan: {totalLoanCount}", totalFont)
                {
                    Alignment = Element.ALIGN_RIGHT
                };
                document.Add(totalLoanParagraph);

                document.Close();
                writer.Close();

                return memoryStream.ToArray();
            }
        }



        //add book reports
        public static byte[] GenerateBookPdfReport(string title, IEnumerable<BookReport> reportData, DateTime startDate, DateTime endDate)
        {
            using (MemoryStream memoryStream = new MemoryStream())
            {
                Document document = new Document(PageSize.A4.Rotate(), 50, 50, 25, 25); // Rotate for more columns
                PdfWriter writer = PdfWriter.GetInstance(document, memoryStream);

                // Assign the page event handler to the PdfWriter
                writer.PageEvent = new PageEvents();

                document.Open();

                // Create the title with background and text color
                iTextSharp.text.Font titleFont = iTextSharp.text.FontFactory.GetFont("Arial", 18, iTextSharp.text.Font.BOLD, BaseColor.WHITE); // White text
                Chunk titleChunk = new Chunk(title, titleFont);

                // Set background color for the title
                PdfPCell titleCell = new PdfPCell(new Phrase(titleChunk))
                {
                    BackgroundColor = new BaseColor(0, 61, 142), // RGB value for #003d8e
                    Border = iTextSharp.text.Rectangle.NO_BORDER, // Use iTextSharp's Rectangle
                    HorizontalAlignment = Element.ALIGN_CENTER
                };

                // Add title to the document in a table format (with no borders)
                PdfPTable titleTable = new PdfPTable(1) { WidthPercentage = 100 };
                titleTable.AddCell(titleCell);
                document.Add(titleTable);

                document.Add(new Paragraph(" ")); // Add some space after the title

                // Add date range under the title
                iTextSharp.text.Font dateRangeFont = iTextSharp.text.FontFactory.GetFont("Arial", 12, iTextSharp.text.Font.NORMAL, BaseColor.BLACK); // Date range font
                string dateRangeText = $"Date: {startDate.ToString("d/M/yyyy")} - {endDate.ToString("d/M/yyyy")}";
                Paragraph dateRangeParagraph = new Paragraph(dateRangeText, dateRangeFont)
                {
                    Alignment = Element.ALIGN_CENTER
                };
                document.Add(dateRangeParagraph);

                document.Add(new Paragraph(" ")); // Add some space after the date range

                // Create a dictionary of category percentages
                var categoryPercentages = new Dictionary<string, float>();
                foreach (var item in reportData)
                {
                    foreach (var category in item.CategoryNames.Split(','))
                    {
                        var trimmedCategory = category.Trim(); // Trim spaces if any
                        if (categoryPercentages.ContainsKey(trimmedCategory))
                            categoryPercentages[trimmedCategory]++;
                        else
                            categoryPercentages.Add(trimmedCategory, 1);
                    }
                }

                // Normalize the category counts to percentages
                float totalCategories = categoryPercentages.Values.Sum();
                foreach (var category in categoryPercentages.Keys.ToList())
                {
                    categoryPercentages[category] = (categoryPercentages[category] / totalCategories) * 100;
                }

                // Generate the pie chart image using System.Drawing (with labels for categories)
                System.Drawing.Image chartImage = ChartUtility.GeneratePieChartWithLabels(categoryPercentages);

                // Convert System.Drawing.Image to iTextSharp.text.Image
                using (MemoryStream chartStream = new MemoryStream())
                {
                    chartImage.Save(chartStream, System.Drawing.Imaging.ImageFormat.Png);  // Save the image as PNG

                    byte[] chartBytes = chartStream.ToArray();  // Convert to byte array

                    // Create iTextSharp Image from byte array
                    iTextSharp.text.Image pdfChartImage = iTextSharp.text.Image.GetInstance(chartBytes);
                    pdfChartImage.ScaleToFit(200f, 200f);  // Optionally scale the image
                    pdfChartImage.Alignment = Element.ALIGN_CENTER;
                    document.Add(pdfChartImage);  // Add the chart image to the document
                }

                // Add the text: Percentage of loan book categories under the pie chart
                iTextSharp.text.Font categoryTextFont = iTextSharp.text.FontFactory.GetFont("Arial", 12, iTextSharp.text.Font.NORMAL, BaseColor.BLACK);
                Paragraph categoryTextParagraph = new Paragraph("Percentage of Add book categories", categoryTextFont)
                {
                    Alignment = Element.ALIGN_CENTER
                };
                document.Add(categoryTextParagraph);

                document.Add(new Paragraph(" ")); // Add some space after the text

                // Group the report data by category
                var groupedByCategory = reportData
                    .GroupBy(r => r.CategoryNames)  // Group by Category
                    .OrderBy(g => g.Key)           // Sort by Category name
                    .ToList();

                // Loop through each category
                foreach (var categoryGroup in groupedByCategory)
                {
                    // Add Category Header
                    iTextSharp.text.Font categoryFont = iTextSharp.text.FontFactory.GetFont("Arial", 14, iTextSharp.text.Font.BOLD, BaseColor.BLACK);
                    Paragraph categoryHeader = new Paragraph($"Category: {categoryGroup.Key}", categoryFont)
                    {
                        Alignment = Element.ALIGN_LEFT
                    };
                    document.Add(categoryHeader);

                    document.Add(new Paragraph(" ")); // Add spacing

                    // Loop through each book in the category
                    foreach (var item in categoryGroup)
                    {
                        // Book Title
                        iTextSharp.text.Font bookTitleFont = iTextSharp.text.FontFactory.GetFont("Arial", 12, iTextSharp.text.Font.BOLD, BaseColor.BLACK);
                        Paragraph bookTitle = new Paragraph($"Book Title: {item.BookTitle}", bookTitleFont)
                        {
                            Alignment = Element.ALIGN_LEFT
                        };
                        document.Add(bookTitle);

                        // Define a table for Book Copy details
                        PdfPTable table = new PdfPTable(5) { WidthPercentage = 100 }; // Adjusted for 4 columns
                        table.SetWidths(new float[] { 20f, 20f, 20f, 20f, 20f }); // Adjust widths accordingly

                        // Add headers for Book Copy details
                        PdfPCell headerCell;

                        // New column header for Book Copy Image
                        headerCell = new PdfPCell(new Phrase("Book Copy Image", bookTitleFont)) { Border = iTextSharp.text.Rectangle.NO_BORDER };
                        table.AddCell(headerCell);

                        headerCell = new PdfPCell(new Phrase("Created At", bookTitleFont)) { Border = iTextSharp.text.Rectangle.NO_BORDER };
                        table.AddCell(headerCell);

                        headerCell = new PdfPCell(new Phrase("Publish Date", bookTitleFont)) { Border = iTextSharp.text.Rectangle.NO_BORDER };
                        table.AddCell(headerCell);

                        headerCell = new PdfPCell(new Phrase("Publish Owner", bookTitleFont)) { Border = iTextSharp.text.Rectangle.NO_BORDER };
                        table.AddCell(headerCell);

                        headerCell = new PdfPCell(new Phrase("ISBN", bookTitleFont)) { Border = iTextSharp.text.Rectangle.NO_BORDER };
                        table.AddCell(headerCell);
                        PdfPCell hrCell = new PdfPCell(new Phrase(" ")) // Empty cell
                        {
                            Colspan = 6, // Span across all columns
                            BorderWidthTop = 1f, // Line thickness
                            BorderWidthBottom = 0f, // No bottom border
                            BorderWidthLeft = 0f,
                            BorderWidthRight = 0f,
                            BorderColorTop = BaseColor.GRAY // Line color
                        };
                        table.AddCell(hrCell);

                        document.Add(new Paragraph(" "));
                        // Add data for the book's first copy
                        PdfPCell dataCell;

                        // Add Book Copy Image if it exists
                        if (item.BookCopyImage != null && item.BookCopyImage.Length > 0)
                        {
                            using (MemoryStream imgStream = new MemoryStream(item.BookCopyImage))
                            {
                                iTextSharp.text.Image bookImage = iTextSharp.text.Image.GetInstance(imgStream);
                                bookImage.ScaleToFit(50f, 50f);  // Scale image to fit the column (adjust size as needed)
                                bookImage.Alignment = Element.ALIGN_CENTER;

                                // Add the image in the new column
                                dataCell = new PdfPCell(bookImage) { Border = iTextSharp.text.Rectangle.NO_BORDER };
                                table.AddCell(dataCell);
                            }
                        }
                        else
                        {
                            // If no image is available, add a default image from the server path
                            string defaultImagePath = "~/images/defaultCoverBook.png"; // Path to the default image

                            // Convert the default image to a byte array
                            string serverPath = HttpContext.Current.Server.MapPath(defaultImagePath);  // Map the relative path to an absolute server path

                            if (File.Exists(serverPath))
                            {
                                // Load the default image
                                iTextSharp.text.Image defaultImage = iTextSharp.text.Image.GetInstance(serverPath);
                                defaultImage.ScaleToFit(50f, 50f);  // Scale image to fit the column
                                defaultImage.Alignment = Element.ALIGN_CENTER;

                                // Add the default image in the new column
                                dataCell = new PdfPCell(defaultImage) { Border = iTextSharp.text.Rectangle.NO_BORDER };
                                table.AddCell(dataCell);
                            }
                            else
                            {
                                // If the default image is not found, show a placeholder text
                                dataCell = new PdfPCell(new Phrase("No Image Available", bookTitleFont)) { Border = iTextSharp.text.Rectangle.NO_BORDER };
                                table.AddCell(dataCell);
                            }
                        }

                        dataCell = new PdfPCell(new Phrase(item.BookCopyCreatedAt.ToShortDateString(), bookTitleFont)) { Border = iTextSharp.text.Rectangle.NO_BORDER };
                        table.AddCell(dataCell);

                        dataCell = new PdfPCell(new Phrase(item.PublishDate.ToShortDateString(), bookTitleFont)) { Border = iTextSharp.text.Rectangle.NO_BORDER };
                        table.AddCell(dataCell);

                        dataCell = new PdfPCell(new Phrase(item.PublishOwner, bookTitleFont)) { Border = iTextSharp.text.Rectangle.NO_BORDER };
                        table.AddCell(dataCell);

                        dataCell = new PdfPCell(new Phrase(item.ISBN, bookTitleFont)) { Border = iTextSharp.text.Rectangle.NO_BORDER };
                        table.AddCell(dataCell);


                        document.Add(table); // Add table to document

                        document.Add(new Paragraph(" ")); // Add space after each book
                    }

                    document.Add(new Paragraph(" ")); // Add some space after the category section
                }

                // Add Total Book Loan count at the bottom of the document
                iTextSharp.text.Font totalFont = iTextSharp.text.FontFactory.GetFont("Arial", 12, iTextSharp.text.Font.BOLD, BaseColor.BLACK);
                float totalBookCount = reportData.Count();
                Paragraph totalBookCountParagraph = new Paragraph($"Total Books Added: {totalBookCount}", totalFont)
                {
                    Alignment = Element.ALIGN_RIGHT
                };
                document.Add(totalBookCountParagraph);

                document.Close();
                writer.Close();

                return memoryStream.ToArray();
            }
        }





    }


}
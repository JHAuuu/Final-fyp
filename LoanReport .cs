using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace fyp
{
    public class LoanReport
    {
        public int LoanId { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public int BookCopyId { get; set; }
        public string BookTitle { get; set; }
        public string CategoryNames { get; set; }
        public string UserName { get; set; }
        public DateTime? LatestReturn { get; set; } // Nullable in case there's no return date
        public byte[] BookCopyImage { get; set; }  // New field for storing the image byte array
        public string ISBN { get; set; }           // New field for ISBN
    }

    public class BookReport
    {
        public int BookId { get; set; }
        public string BookTitle { get; set; }
        public string BookDesc { get; set; }
        public string BookSeries { get; set; }
        public DateTime CreatedAt { get; set; }
        public string CategoryNames { get; set; }  // Updated to match query alias
        public string AuthorNames { get; set; }    // Multiple authors
        public string ISBN { get; set; }
        public DateTime PublishDate { get; set; }
        public string PublishOwner { get; set; }
        public bool IsAvailable { get; set; }
        public DateTime BookCopyCreatedAt { get; set; }  // Date when the book copy was created
        public byte[] BookCopyImage { get; set; }  // Byte array for the Book Copy Image
    }
}
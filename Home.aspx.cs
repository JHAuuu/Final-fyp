using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Security.Claims;
using System.Data;

namespace fyp
{
    public partial class Home : System.Web.UI.Page
    {
        public static int userid = 0;
        protected void Page_Load(object sender, EventArgs e)
        {
            DataTable getbook = getRandomBooks();
            if (getbook.Rows.Count > 0)
            {
                rptBook.DataSource = getbook;
                rptBook.DataBind();
            }
            if (!IsPostBack)
            {
                if (User.Identity.IsAuthenticated)
                {
                    // Use ClaimsPrincipal to get claims
                    var identity = (System.Security.Claims.ClaimsPrincipal)User;

                    // Extract claims
                    string userId = identity.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                    string userRole = identity.FindFirst(ClaimTypes.Role)?.Value;
                    string userName = identity.FindFirst(ClaimTypes.Name)?.Value;

                    // Store user details in Session for further use (optional)
                    Session["userId"] = userId;
                    Session["UserRole"] = userRole;
                    Session["UserName"] = userName;

                    if (!string.IsNullOrEmpty(userId) && int.TryParse(userId, out int parsedUserId))
                    {
                        userid = parsedUserId;
                    }

                    // Check the role and hide the dropdown if not Admin or Staff
                    if (userRole != "Admin" && userRole != "Staff")
                    {
                        DashDropdown.Visible = false; // Hides the dropdown
                    }
                    else
                    {
                        history.Visible = false;
                        fav.Visible = false;
                    }

                }
                else
                {
                    // Anonymous user: ensure safe handling
                    Session["userId"] = null;
                    Session["UserRole"] = null;
                    Session["UserName"] = null;

                    //userid = 0; // Default for anonymous users
                    // For unauthenticated users, hide the dropdown
                    DashDropdown.Visible = false;
                    AccDropdown.Visible = false;
                }


                
            }
        }

        public int getNotiCount()
        {
            try
            {
                if (Session["UserId"] != null && !String.IsNullOrEmpty(Session["UserId"].ToString()))
                {
                    string userid = Session["UserId"].ToString();
                    string query = @"SELECT COUNT(*) AS TotalItems
FROM (
    SELECT 
        i.InboxId AS ItemId
    FROM Inbox i
    LEFT JOIN InboxStatus s ON i.InboxId = s.InboxId AND i.UserId = s.UserId
    WHERE i.UserId = @userId AND s.[Read] = 'false'

    UNION ALL

    SELECT 
        a.AnnouncementId AS ItemId
    FROM Announcement a
    LEFT JOIN AnnouncementStatus s ON a.AnnouncementId = s.AnnouncementId
    WHERE s.UserId = @userId AND s.[Read] = 'false'
) AS CombinedItems;";

                    int getTotalNoti = Convert.ToInt32(DBHelper.ExecuteScalar(query, new string[]{
                        "userId", userid
                }));

                    return getTotalNoti;
                }
                else
                {
                    return 0;
                }

            }
            catch (Exception ex)
            {
                Console.WriteLine("Error in getNotiCount: " + ex.Message);
                return 0;
            }
        }


        public DataTable getRandomBooks()
        {
            try
            {
                string query = @"SELECT TOP 10 b.BookId, b.BookTitle, b.BookImage, b.BookDesc
FROM Book b
ORDER BY NEWID(); 
";

                DataTable originalDt = DBHelper.ExecuteQuery(query, new string[] { });


                return originalDt;

            }
            catch (Exception ex)
            {
                return new DataTable();
            }
        }

    }
}

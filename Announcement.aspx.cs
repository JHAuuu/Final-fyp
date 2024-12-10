using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace fyp
{
    public partial class Announcement : System.Web.UI.Page
    {
        static int userid = 0;
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Session["UserId"] != null)
                {
                    userid = Convert.ToInt32(Session["UserId"].ToString());
                }


                DataTable dtNoti = getAllNoti();
                if(dtNoti.Rows.Count > 0)
                {
                    rptMessage.DataSource = dtNoti;
                    rptMessage.DataBind();
                }
            }
        }

        public DataTable getAllNoti()
        {
            try
            {
                string query = @"SELECT 
    i.InboxId AS ItemId,
    i.InboxTitle AS Title,
    i.InboxContent AS Content,
    i.SendAt AS DateTime,
    'Inbox' AS ItemType,
    i.UserId,
    CASE WHEN s.[Read] = 0 THEN 1 ELSE 0 END AS IsUnread
FROM Inbox i
LEFT JOIN InboxStatus s ON i.InboxId = s.InboxId AND i.UserId = s.UserId
WHERE i.UserId = @userId

UNION ALL

SELECT 
    a.AnnouncementId AS ItemId,
    a.Title,
    a.Content,
    a.DateTime,
    'Announcement' AS ItemType,
    NULL AS UserId,
    CASE WHEN s.[Read] = 0 THEN 1 ELSE 0 END AS IsUnread
FROM Announcement a
LEFT JOIN AnnouncementStatus s ON a.AnnouncementId = s.AnnouncementId
WHERE s.UserId = @userId
ORDER BY DateTime DESC, ItemId DESC;
";
                DataTable dt = DBHelper.ExecuteQuery(query, new string[]
                {
                    "userId",userid.ToString()
                });


                return dt;




            }
            catch (Exception ex)
            {
                return new DataTable();
            }
        }


        [System.Web.Services.WebMethod(Description = "Change Status")]
        public static string changeStatus(string table, string itemId)
        {
            try
            {
                string tableName = table + "Status";
                string IdName = table + "Id";
                string query = $"UPDATE {tableName} SET [Read] = 1 WHERE {IdName} = @id AND UserId = @userid";

                int success = DBHelper.ExecuteNonQuery(query, new string[]{
                    "id",itemId,
                    "userid",userid.ToString()

                });
                if (success > 0)
                {
                    return "SUCCESS";
                }
                else
                {
                    return "Fail";
                }

            }
            catch (Exception ex)
            {
                return "Fail";
            }
        }
    }
}
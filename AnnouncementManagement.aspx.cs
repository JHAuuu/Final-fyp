using System;
using fyp.Authentication;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using Microsoft.AspNet.SignalR;

namespace fyp
{
    public partial class AnnouncementManagement : AdminPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            var master = this.Master as DashMasterPage;
            if (master != null)
            {
                master.titleText = "Announcement Management";
            }

            if (!IsPostBack)
            {
                // Default SelectCommand to show all announcements
                SqlDSourceDisplay.SelectCommand = "SELECT * FROM [Announcement] ORDER BY [DateTime] DESC";
                RepeaterAnnouncements.DataBind();
            }
        }

        protected void RepeaterAnnouncements_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int announcementId = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "Delete")
            {
                // Delete announcement
                SqlDSourceDisplay.DeleteCommand = "DELETE FROM AnnouncementStatus WHERE AnnouncementId = @AnnouncementId;";
                SqlDSourceDisplay.DeleteCommand = "DELETE FROM Announcement WHERE AnnouncementId = @AnnouncementId;";

                SqlDSourceDisplay.DeleteParameters.Clear();
                SqlDSourceDisplay.DeleteParameters.Add("AnnouncementId", announcementId.ToString());
                SqlDSourceDisplay.Delete();
            }
            if (e.CommandName == "Edit")
            {
                // Fetch announcement data by ID (including LastUpdated)
                String getAnnouncement = "SELECT * FROM [Announcement] WHERE AnnouncementId = @AnnouncementId";
                object[] checkParams = { "@AnnouncementId", announcementId };

                DataTable rt = fyp.DBHelper.ExecuteQuery(getAnnouncement, checkParams);

                if (rt.Rows.Count > 0)
                {
                    // Set the modal fields with existing data
                    EditTitle.Text = rt.Rows[0]["Title"].ToString();
                    EditContent.Text = rt.Rows[0]["Content"].ToString();

                    Label lblModifiedStatus = (Label)RepeaterAnnouncements.Items[0].FindControl("lblModifiedStatus");
                    if (lblModifiedStatus != null)
                    {
                        // Update the label text with the LastUpdated value
                        lblModifiedStatus.Text = rt.Rows[0]["LastUpdated"] != DBNull.Value ?
                                                "Last Updated: " + Convert.ToDateTime(rt.Rows[0]["LastUpdated"]).ToString("yyyy-MM-dd HH:mm") :
                                                "Not updated yet";
                    }
                }

                // Store announcement ID for the save function
                ViewState["EditAnnouncementId"] = announcementId;

                // Show the modal
                ScriptManager.RegisterStartupScript(this, this.GetType(), "editModal", "openModal();", true);
            }

        }

        protected void SaveEditButton_Click(object sender, EventArgs e)
        {
            if (ViewState["EditAnnouncementId"] != null)
            {
                int announcementId = (int)ViewState["EditAnnouncementId"];
                SqlDSourceDisplay.UpdateParameters.Clear();
                // Update the announcement record in the database
                SqlDSourceDisplay.UpdateCommand = "UPDATE Announcement SET Title = @Title, Content = @Content WHERE AnnouncementId = @AnnouncementId";
                SqlDSourceDisplay.UpdateParameters.Add("Title", EditTitle.Text);
                SqlDSourceDisplay.UpdateParameters.Add("Content", EditContent.Text);
                SqlDSourceDisplay.UpdateParameters.Add("AnnouncementId", announcementId.ToString());
                SqlDSourceDisplay.Update();

                // Clear ViewState
                ViewState["EditAnnouncementId"] = null;

                // Hide modal
                ScriptManager.RegisterStartupScript(this, this.GetType(), "editModal", "$('#editModal').modal('hide');", true);
            }
        }

        protected void pushAnnouncement_Click(object sender, EventArgs e)
        {
            string title = NewTitle.Text;
            string content = NewContent.Text;

            string insertQuery = "INSERT INTO Announcement (DateTime, Title, Content) " +
                     "VALUES (@DateTime, @Title, @Content)";

            object[] insertParams = {
                "@DateTime", DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"),
                "@Title", title,
                "@Content", content
            };

            int rowsAffected = fyp.DBHelper.ExecuteNonQuery(insertQuery, insertParams);

            if (rowsAffected > 0)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "SuccessAlert", "alert('Push Announcement successfully!');", true);
                // Notify all connected clients about the new announcement using SignalR
                var context = GlobalHost.ConnectionManager.GetHubContext<NotificationHub>();
                context.Clients.All.ReceiveAnnouncement(title, content);  // This calls the `ReceiveAnnouncement` method in clients

                // Re-bind the repeater to show the updated list of announcements
                RepeaterAnnouncements.DataBind();
            }
            else
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ErrorAlert", "alert('Failed to create announcement.');", true);
            }

            // Clear the text fields after saving and close the modal
            NewTitle.Text = string.Empty;
            NewContent.Text = string.Empty;
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            string searchText = searchBar.Text.Trim();

            if (!string.IsNullOrEmpty(searchText))
            {
                // Update SelectCommand with search filter if searchText is not empty
                SqlDSourceDisplay.SelectCommand = "SELECT * FROM [Announcement] WHERE ([Title] LIKE '%' + @SearchText + '%' OR [Content] LIKE '%' + @SearchText + '%') ORDER BY [DateTime] DESC";
                SqlDSourceDisplay.SelectParameters.Clear();
                SqlDSourceDisplay.SelectParameters.Add("SearchText", searchText);
            }
            else
            {
                // Reset to show all announcements if search text is empty
                SqlDSourceDisplay.SelectCommand = "SELECT * FROM [Announcement] ORDER BY [DateTime] DESC";
            }

            RepeaterAnnouncements.DataBind(); // Rebind Repeater to apply the filter
        }
    }
}
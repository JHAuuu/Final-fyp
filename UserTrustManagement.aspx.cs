using System;
using fyp.Authentication;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
namespace fyp
{
    public partial class UserTrustManagement : AdminPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserRole"] == null)
            {
                Response.Redirect("Login.aspx");
            }
            if (Session["UserRole"]?.ToString() == "User")
            {
                Response.Redirect("Home.aspx");
            }

            var master = this.Master as DashMasterPage;
            if (master != null)
            {
                master.titleText = "User Trust Management";
            }
        }

        [System.Web.Services.WebMethod]
        public static object GetUserData(int UserId)
        {
            string checkQuery = @"
            SELECT 
                u.UserId,
                u.UserName,
                t.TrustScore,
                t.TrustLvl
            FROM 
                [User] u
            JOIN 
                Patron p ON u.UserId = p.UserId
            JOIN 
                Trustworthy t ON p.PatronId = t.PatronId
            WHERE 
                u.UserId = @UserId";

            object[] checkParams = { "@UserId", UserId };

            DataTable resultTable = fyp.DBHelper.ExecuteQuery(checkQuery, checkParams);

            if (resultTable.Rows.Count > 0)
            {
                DataRow row = resultTable.Rows[0];

                // Get trust score and determine borrowing eligibility message
                int trustScore = Convert.ToInt32(row["TrustScore"]);
                string borrowingMessage;

                if (trustScore == 100)
                    borrowingMessage = "High trust level: User can borrow three books.";
                else if (trustScore >= 90)
                    borrowingMessage = "Medium Trust level: User can borrow two books.";
                else if (trustScore >= 80)
                    borrowingMessage = "Low trust level: Can borrow one book.";
                else
                    borrowingMessage = "This user cannot borrow books at this time. Please wait until your trust level improves.";

                // Return user data along with borrowing message
                var userData = new
                {
                    userId = row["UserId"].ToString(),
                    name = row["UserName"].ToString(),
                    trustPoints = trustScore,
                    trustLevel = row["TrustLvl"].ToString(),
                    borrowingMessage = borrowingMessage
                };

                return userData;
            }
            return null;
        }
    }
}
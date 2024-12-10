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
        u.UserRole,
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

                // Get role and trust level details
                string userRole = row["UserRole"].ToString();
                int trustScore = Convert.ToInt32(row["TrustScore"]);
                string trustLevel = row["TrustLvl"].ToString();

                string borrowingMessage;

                // Determine borrowing eligibility and behavior comments
                switch (trustLevel)
                {
                    case "Very High":
                        borrowingMessage = $"As a {userRole} with a 'Very High' trust level ({trustScore}), you have demonstrated excellent borrowing behavior. You are allowed to borrow up to 5 books.";
                        break;
                    case "High":
                        borrowingMessage = $"As a {userRole} with a 'High' trust level ({trustScore}), your borrowing behavior is commendable. You are allowed to borrow up to 3 books.";
                        break;
                    case "Medium":
                        borrowingMessage = $"As a {userRole} with a 'Medium' trust level ({trustScore}), you have shown fair behavior. You are allowed to borrow up to 2 books.";
                        break;
                    case "Low":
                        borrowingMessage = $"As a {userRole} with a 'Low' trust level ({trustScore}), your borrowing behavior requires improvement. You are allowed to borrow only 1 book.";
                        break;
                    case "Restricted":
                        borrowingMessage = $"Your account is restricted due to a low trust score ({trustScore}). This indicates poor borrowing behavior. You cannot borrow books at this time. Please improve your trust score to at least 80 to regain borrowing privileges.";
                        break;
                    default:
                        borrowingMessage = "Trust level not recognized. Please contact the administrator.";
                        break;
                }

                // Return user data along with borrowing message
                var userData = new
                {
                    userId = row["UserId"].ToString(),
                    name = row["UserName"].ToString(),
                    role = userRole,
                    trustPoints = trustScore,
                    trustLevel = trustLevel,
                    borrowingMessage = borrowingMessage
                };

                return userData;
            }

            // Return null if no data is found
            return null;
        }


    }
}
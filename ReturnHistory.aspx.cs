using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace fyp
{
    public partial class ReturnHistory : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                RepeaterLoanHistory.DataBind();
            }
        }

        protected void RepeaterLoanHistory_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                // Find the Label control for status
                Label lblLoanStatus = e.Item.FindControl("lblLoanStatus") as Label;
                if (lblLoanStatus != null)
                {
                    string status = DataBinder.Eval(e.Item.DataItem, "Status").ToString().ToLower();

                    // Append additional CSS class based on the status
                    switch (status)
                    {
                        case "loaned":
                            lblLoanStatus.CssClass += " loaned";
                            break;
                        case "returned":
                            lblLoanStatus.CssClass += " returned";
                            break;
                        case "overdue":
                            lblLoanStatus.CssClass += " overdue";
                            break;
                        case "preloaning":
                            lblLoanStatus.CssClass += " preloaning";
                            break;
                        case "reserved":
                            lblLoanStatus.CssClass += " reserved";
                            break;
                        case "returning":
                            lblLoanStatus.CssClass += " returning";
                            break;
                        case "loaning": // New status for "loaning"
                            lblLoanStatus.CssClass += " loaning";
                            break;
                        default:
                            lblLoanStatus.CssClass += " unknown";
                            break;
                    }
                }
            }
        }

        protected void btnViewDetail_Click(object sender, CommandEventArgs e)
        {
            // Get the BookCopyId from the CommandArgument
            string LoanId = e.CommandArgument.ToString();

            // Redirect to a detailed view page
            Response.Redirect($"ReturnViewDetail.aspx?LoanId={LoanId}");
        }

        protected void logOut_Click(object sender, EventArgs e)
        {
            Session["ReturnUserId"] = null;

            Response.Redirect("ReturnBookManagement.aspx");
        }
    }
}
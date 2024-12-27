<%@ Page Title="History" MasterPageFile="~/Master/DashMasterPage.Master" Language="C#" AutoEventWireup="true" CodeBehind="UserHistory.aspx.cs" Inherits="fyp.UserHistory" %>

<asp:Content ID="content1" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        .container {
            border-radius: 1px;
            position: relative;
            display: flex;
            justify-content: center;
        }

        .history-container {
            border-style: solid;
            border-color: #666;
            border-width: 2px;
            margin-top: 20px;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
        }

        .history-item {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 12px 20px;
            border-bottom: 1px solid #ddd;
            transition: background-color 0.3s ease;
        }

            .history-item:hover {
                background-color: #f0f0f0;
            }

        .time {
            width: 200px;
            font-size: 14px;
            color: #666;
            text-align: center;
        }

        .details {
            flex-grow: 1;
            padding-left: 15px;
        }

            .details .book-title {
                font-size: 16px;
                font-weight: bold;
                color: #333;
            }

            .details .description {
                font-size: 14px;
                color: #777;
            }

        .view-detail {
            margin-left: 20px;
        }

            .view-detail .asp-button {
                background-color: #007bff;
                color: white;
                padding: 8px 16px;
                border: none;
                border-radius: 4px;
                font-size: 14px;
                cursor: pointer;
                transition: background-color 0.3s ease, transform 0.3s ease;
                text-transform: uppercase;
            }

                .view-detail .asp-button:hover {
                    background-color: #0056b3;
                    transform: scale(1.05);
                }

                .view-detail .asp-button:active {
                    background-color: #003f7f;
                    transform: scale(1);
                }

            .status {
        width: 150px;
        text-align: center;
        margin: auto; /* Center align the status section */
    }

    /* General styling for the status label */
    .status-label {
        display: inline-block;
        font-size: 14px;
        font-weight: bold;
        padding: 8px 12px;
        border-radius: 8px;
        text-transform: uppercase;
        color: white;
        box-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
        transition: transform 0.3s ease, box-shadow 0.3s ease;
    }

    /* Different colors for statuses */
    .status-label.loaning {
        background-color: #007bff; /* Blue for loaned */
    }

    .status-label.returned {
        background-color: #28a745; /* Green for returned */
    }

    .status-label.preloaning {
        background-color: #ffc107; /* Yellow for pre-loaning */
    }

    .status-label.overdue {
        background-color: #dc3545; /* Red for overdue */
    }

    .status-label.returning {
    background-color: #17a2b8; /* Cyan for returning */
}

    /* Hover effect for better interaction */
    .status-label:hover {
        transform: scale(1.05); /* Slight zoom effect */
        box-shadow: 0 4px 6px rgba(0, 0, 0, 0.3);
    }
    </style>
    <asp:SqlDataSource
    ID="SqlDataSourceLoanDetails"
    runat="server"
    ConnectionString="<%$ ConnectionStrings:ConnectionString %>"
    SelectCommand="
         SELECT 
                U.UserId,
                STRING_AGG(A.AuthorName, ', ') AS AuthorName,
                L.LoanId,
                L.StartDate,
                L.EndDate,
                L.Status,
                BC.BookCopyId,
                BC.BookCopyImage,
                B.BookTitle
            FROM Loan L
            JOIN Patron P ON L.PatronId = P.PatronId
            JOIN [User] U ON P.UserId = U.UserId
            JOIN BookCopy BC ON L.BookCopyId = BC.BookCopyId
            JOIN Book B ON BC.BookId = B.BookId
            JOIN BookAuthor BA ON B.BookId = BA.BookId
            JOIN Author A ON BA.AuthorId = A.AuthorId
            WHERE U.UserId = @UserId
            GROUP BY U.UserId, L.LoanId, L.StartDate, L.EndDate, L.Status, BC.BookCopyId, BC.BookCopyImage, B.BookTitle;">
    <SelectParameters>
        <asp:QueryStringParameter Name="UserId" QueryStringField="UserId" Type="Int32" />
    </SelectParameters>
</asp:SqlDataSource>
    <div class="row">
        <h2>Your History</h2>
    </div>

    <div class="history-container">
        <!--Body Content-->
        <asp:Repeater ID="RepeaterLoanHistory" runat="server" DataSourceID="SqlDataSourceLoanDetails" OnItemDataBound="RepeaterLoanHistory_ItemDataBound">
    <ItemTemplate>
        <div class="history-item">
            <div class="status">
                <asp:Label 
                    ID="lblLoanStatus" 
                    runat="server" 
                    CssClass='<%# "status-label " + Eval("Status").ToString().ToLower() %>' 
                    Text='<%# Eval("Status") %>'>
                </asp:Label>
            </div>
            <div class="details">
                <div class="book-title"><%# Eval("BookTitle") %></div>
                <div class="description">
                    <span>Loan Date: </span><%# Eval("StartDate", "{0:dd MMM yyyy hh:mm tt}") %><br />
                    <span>Return Date: </span><%# Eval("EndDate", "{0:dd MMM yyyy hh:mm tt}") %><br />
                    <span>Book Copy ID: </span><%# Eval("BookCopyId") %>
                </div>
            </div>
            <div class="view-detail">
                <asp:Button ID="btnViewDetail" runat="server" CssClass="asp-button" Text="View Detail" CommandArgument='<%# Eval("LoanId") %>' OnCommand="btnViewDetail_Click" />
            </div>
        </div>
    </ItemTemplate>
</asp:Repeater>
    </div>
</asp:Content>

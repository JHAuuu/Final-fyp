<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ReturnHistory.aspx.cs" Inherits="fyp.ReturnHistory" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Return History</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css" />
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600&display=swap');
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f8f9fa; /* Light background */
            color: #333;
        }

        body, html {
        height: 100%; /* Full height for proper layout */
        display: flex;
        flex-direction: column;
    }

        header {
            background-color: #343a40; /* Dark header */
            color: white;
            padding: 20px;
            text-align: center;
        }

        .container {
        flex: 1; /* Ensures the container stretches to fill the space */
        max-width: 900px;
        margin: 20px auto;
        padding: 20px;
        background-color: white;
        border-radius: 8px;
        box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
    }

        .row h2 {
            text-align: center;
            color: #007bff; /* Primary color */
            margin-bottom: 20px;
        }

        .history-container {
            border: 1px solid #dee2e6;
            border-radius: 8px;
            overflow: hidden; /* Clean border edges */
            background-color: #ffffff; /* White background for history items */
        }

        .history-item {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 15px 20px;
            border-bottom: 1px solid #dee2e6;
            transition: background-color 0.3s ease;
        }

        .history-item:hover {
            background-color: #f1f3f5; /* Light hover effect */
        }

        .time {
            width: 200px;
            font-size: 14px;
            color: #666;
            text-align: center;
        }

        .details {
            flex-grow: 1;
            padding-left: 20px;
        }

        .details .book-title {
            font-size: 18px;
            font-weight: bold;
            color: #343a40; /* Darker text color */
        }

        .details .description {
            font-size: 14px;
            color: #6c757d;
        }

        .view-detail {
            margin-left: 20px;
        }

        .view-detail .asp-button {
            background-color: #007bff; /* Primary blue */
            color: white;
            padding: 10px 18px;
            border: none;
            border-radius: 4px;
            font-size: 14px;
            cursor: pointer;
            transition: background-color 0.3s ease, transform 0.3s ease;
            text-transform: uppercase;
        }

        .view-detail .asp-button:hover {
            background-color: #0056b3; /* Darker blue on hover */
            transform: scale(1.05);
        }

        .view-detail .asp-button:active {
            background-color: #003f7f;
            transform: scale(1);
        }

        .status {
            width: 150px;
            text-align: center;
            margin: auto;
        }

        .status-label {
            display: inline-block;
            font-size: 14px;
            font-weight: bold;
            padding: 8px 12px;
            border-radius: 20px; /* Rounder badge */
            text-transform: uppercase;
            color: white;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
        }

        .status-label.loaned {
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

        .status-label.loaning {
            background-color: #6f42c1; /* Purple for loaning */
        }

        .status-label:hover {
            transform: scale(1.05); /* Slight zoom effect */
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.3);
        }

        footer {
            display: flex;
            justify-content: center;
            align-items: center;
            height: 80px;
            background: linear-gradient(to right, #004d40, #00695c); /* Footer gradient */
            color: white;
            font-size: 14px;
        }

        .container {
        min-height: 600px; /* Ensures the container has some height even with one item */
    }



        /* Responsive adjustments */
        @media (max-width: 768px) {
            .history-item {
                flex-direction: column;
                align-items: flex-start;
            }

            .details {
                padding-left: 0;
                margin-top: 10px;
            }

            .view-detail {
                margin-left: 0;
                margin-top: 10px;
            }

            .status {
                margin: 10px 0;
            }
        }
        .btn-logout {
            position: fixed; /* Fixed position */
            bottom: 80px; /* Distance from the bottom */
            right: 30px; /* Distance from the left */
            background-color: #dc3545; /* Red button */
            color: white;
            padding: 10px 15px;
            font-size: 14px;
            border: none;
            border-radius: 50px;
            cursor: pointer;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.2);
            transition: background-color 0.3s, transform 0.2s;
            text-transform: uppercase;
            z-index: 1000; /* Ensure it's always on top */
        }

            .btn-logout:hover {
                background-color: #b52a38; /* Darker red on hover */
                transform: scale(1.05);
            }

            .btn-logout:active {
                background-color: #8c202d; /* Even darker red on click */
                transform: scale(1);
            }

    </style>
</head>
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
    <selectparameters>
        <asp:SessionParameter Name="UserId" SessionField="ReturnUserId" Type="Int32" />
    </selectparameters>
</asp:SqlDataSource>
<body>
    <form id="form1" runat="server">
        <header>
            <h1>Library Management System</h1>
        </header>
        <div class="container">
            <div class="row">
                <h2>Your History</h2>
            </div>

            <div class="history-container">
                <asp:Repeater ID="RepeaterLoanHistory" runat="server" DataSourceID="SqlDataSourceLoanDetails" OnItemDataBound="RepeaterLoanHistory_ItemDataBound">
                    <ItemTemplate>
                        <div class="history-item">
                            <div class="status">
                                <asp:Label
                                    ID="lblLoanStatus"
                                    runat="server"
                                    CssClass='<%# "status-label " + Eval("Status").ToString().ToLower() %>'
                                    Text='<%# Eval("Status") %>'></asp:Label>
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
        </div>
        <asp:Button ID="btnLogout" runat="server" CssClass="btn-logout" OnClick="logOut_Click" Text="Log Out"></asp:Button>
        <footer>
            <p>&copy; 2024 Library Management System. All rights reserved.</p>
        </footer>
    </form>
</body>
</html>

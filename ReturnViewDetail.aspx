<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ReturnViewDetail.aspx.cs" Inherits="fyp.ReturnViewDetail" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>View History</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css" />
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.6.0/css/all.min.css" />
    <style>
    @import url('https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600&display=swap');
    body {
        font-family: 'Poppins', sans-serif;
        margin: 0;
        padding: 0;
        background-color: #f8f9fa;
    }

    .wrapper {
        background: #fff;
        margin: 2em auto;
        padding: 2em;
        border-radius: 8px;
        box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
        max-width: 800px;
    }

    i {
        margin-top: 30px;
        margin-left: 30px;
        cursor: pointer;
        font-size: 1.3rem;
        color: black;
    }

    .wrapper h2 {
        text-align: center;
        font-size: 28px;
        margin-bottom: 1em;
        color: #343a40;
    }

    .info-container {
        display: flex;
        flex-wrap: wrap;
        justify-content: space-between;
        margin-top: 1.5em;
    }

    .info-item {
        flex: 0 0 48%;
        margin-bottom: 1em;
    }

    .info-item h5 {
        font-size: 14px;
        font-weight: bold;
        color: #6c757d;
        margin-bottom: 0.5em;
    }

    .info-item span {
        font-size: 16px;
        color: #343a40;
    }

    .book-image-container {
        display: flex;
        justify-content: center;
        margin-bottom: 2em;
    }

    .book-image-container img {
        border-radius: 8px;
        max-width: 200px;
        height: auto;
    }

    .status {
        text-align: center;
        margin-top: 1em;
        font-weight: bold;
        padding: 8px 16px;
        border-radius: 4px;
        color: #fff;
    }

    .status.returned {
        background-color: #28a745;
    }

    .status.loaned {
        background-color: #007bff;
    }

    .status.overdue {
        background-color: #dc3545;
    }

    .status.approving {
        background-color: #ffc107;
    }

    hr {
        margin: 2em 0;
        border: 0;
        height: 1px;
        background: #e9ecef;
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

            .btn-logout i {
    font-size: 14px; /* Icon size consistent with text */
    margin: unset;
    color:white;
}

</style>

</head>
<body>
    <form id="form1" runat="server">
        <a href="javascript:void(0);" onclick="history.back()">
                    <i class="fa-solid fa-chevron-left"></i>
                </a>
        <div class="wrapper">
    <h2>Loan Details</h2>
    <div class="book-image-container">
        <img id="bookImage" runat="server" src="images/defaultCoverBook.png" alt="Book Cover">
    </div>
    <section>
        <div class="info-container">
            <div class="info-item">
                <h5>Title:</h5>
                <span id="lblTitle" runat="server"></span>
            </div>
            <div class="info-item">
                <h5>Publish Date:</h5>
                <span id="lblPublishDate" runat="server"></span>
            </div>
            <div class="info-item">
                <h5>Publish Owner:</h5>
                <span id="lblPublishOwner" runat="server"></span>
            </div>
            <div class="info-item">
                <h5>Status:</h5>
                <span id="lblStatus" runat="server" class="status"></span>
            </div>
            <div class="info-item">
                <h5>Start Date:</h5>
                <span id="lblStartDate" runat="server"></span>
            </div>
            <div class="info-item">
                <h5>End Date:</h5>
                <span id="lblEndDate" runat="server"></span>
            </div>
            <div class="info-item">
                <h5>Approval:</h5>
                <span id="lblApproval" runat="server"></span>
            </div>
            <div class="info-item">
                <h5>Latest Return Book Date:</h5>
                <span id="lblLatestReturn" runat="server"></span>
            </div>
        </div>
    </section>
    <hr />
    <section id="penaltySection" runat="server" visible="false">
        <h3>Penalty</h3>
        <div class="info-container">
            <div class="info-item">
                <h5>Total Fine:</h5>
                <span id="lblTotalFine" runat="server"></span>
            </div>
            <div class="info-item">
                <h5>Date Payed:</h5>
                <span id="lblDatePayed" runat="server"></span>
            </div>
        </div>
    </section>
        <asp:Button ID="btnLogout" runat="server" CssClass="btn-logout" OnClick="logOut_Click" Text="Log Out"></asp:Button>
</div>
    </form>
</body>
</html>

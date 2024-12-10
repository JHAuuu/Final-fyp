<%@ Page Title="Loan Detail" MasterPageFile="~/Master/DashMasterPage.Master" Language="C#" AutoEventWireup="true" CodeBehind="UserLoanDetail.aspx.cs" Inherits="fyp.UserLoanDetail" %>

<asp:Content ID="content1" ContentPlaceHolderID="MainContent" runat="server">
    <style>
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
    </style>
    <div class="wrapper">
    <h2>Loan Details</h2>
    <div class="book-image-container">
        <img id="bookImage" runat="server" src="Image/defaultCoverBook.png" alt="Book Cover">
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
                <h5>Latest Return:</h5>
                <span id="lblLatestReturn" runat="server"></span>
            </div>
        </div>
    </section>
</div>
</asp:Content>
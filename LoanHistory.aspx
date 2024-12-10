<%@ Page Title="" Language="C#" MasterPageFile="~/Master/Client.Master" AutoEventWireup="true" CodeBehind="LoanHistory.aspx.cs" Inherits="fyp.LoanHistory" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Loan History
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <link rel="stylesheet" href="assets/css/loanHistory.css" />
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">

    <div class="row history-link">
        <div class="history-link"><a href="History.aspx">History</a></div>
        <div class="history-link"><a href="LoanHistory.aspx">Loan History</a></div>
    </div>
    <div class="row">
        <header>
            <h2>Loan History</h2>
        </header>
    </div>

    <asp:Panel runat="server" ID="loanEmptyMessage" Visible="false">
        <div class="no-data-message">
            <p>No loaned record at the moment.</p>
        </div>
    </asp:Panel>

    <div class="history-container">

        <!--Body Content-->

        <asp:Repeater runat="server" ID="rptLoan">
            <itemtemplate>
                <div class="history-item">
                    <img src="images/bookimg2.jpg" width="150" alt="" />
                                    <div class="time"><%# (DateTime.Parse(Eval("LatestReturn").ToString()) - DateTime.Parse(Eval("StartDate").ToString())).Days %> Days Borrowed</div>
                    <div class="details">
                        <div class="book-title"><%# Eval("BookTitle")%></div>
                        <div class="description">
                            <span>Date: </span> <%# string.Format("{0:yyyy-MM-dd} to {1:yyyy-MM-dd}", Eval("StartDate"), Eval("LatestReturn")) %><br />
                            <span>ISBN: </span><%# Eval("ISBN")%>
                        </div>
                    </div>
                    <div class="view-detail">
                        <button style="width: 125px; padding: 5px 10px; margin-right: 20px;" onclick="window.location.href = 'LoanDetail.aspx?LoanId=<%# Eval("LoanId") %>';">View Detail</button>
                    </div>
                </div>

            </itemtemplate>
        </asp:Repeater>
    </div>

</asp:Content>
<asp:Content ID="Content4" ContentPlaceHolderID="ScriptContent" runat="server">
        <script src="assets/js/jquery.min.js"></script>
    <script src="assets/js/jquery.dropotron.min.js"></script>
    <script src="assets/js/jquery.scrolly.min.js"></script>
    <script src="assets/js/jquery.scrollex.min.js"></script>
    <script src="assets/js/browser.min.js"></script>
    <script src="assets/js/breakpoints.min.js"></script>
    <script src="assets/js/util.js"></script>
            <script src="assets/js/sweetalert2/sweetalert2.min.js"></script>
</asp:Content>

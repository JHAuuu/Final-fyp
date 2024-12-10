<%@ Page Title="" Language="C#" MasterPageFile="~/Master/Client.Master" AutoEventWireup="true" CodeBehind="RecommendForUser.aspx.cs" Inherits="fyp.RecommendForUser" %>


<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Recommendation By Others Users
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=no" />
    <meta charset="utf-8" />

    <link rel="stylesheet" href="assets/css/main.css" />
    <link rel="stylesheet" href="assets/css/modal.css" />
    <link rel="stylesheet" href="assets/css/recommendation.css" />
    <link rel="stylesheet" href="assets/css/sweetalert2-theme-bootstrap-4/bootstrap-4.min.css">

</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container">
        <div class="row history-link">
            <div class="history-link"><a href="Recommendation.aspx">Recomendation By User Preferences</a></div>
            <div class="history-link"><a href="RecommendByUsers.aspx">Recommenadtion By Others User</a></div>
            <div class="history-link"><a href="RecommendForUser.aspx">Recommenadtion For User</a></div>
        </div>
        <header>
            <h2><a href="#">Recommendation</a></h2>
        </header>
        <div class="book-item-container">
            <!-- Repeat similar structure for each book item, or dynamically generate -->
            <asp:Panel ID="pnlBooks" runat="server">
                <asp:Repeater ID="rptBooks" runat="server" OnPreRender="rptBooks_PreRender">
                    <ItemTemplate>
                        <div class="book-item">
                            <div class="book-details">
                                <div class="book-image">
                                    <img src='<%# Eval("BookImage") != DBNull.Value ? Eval("BookImage"): "images/defaultCoverBook.png"  %> ' alt="Book Cover">
                                </div>
                                <div class="book-info">
                                    <a href="BookDetail.aspx">
                                        <h2 class="book-title"><%# Eval("BookTitle") %></h2>
                                    </a>
                                    <p class="book-detail"><span>Category: </span><%# Eval("CategoryNames") %></p>
                                    <p class="book-detail"><%# !String.IsNullOrEmpty(Eval("BookSeries")?.ToString()) ? "<span>Series:</span> " + Eval("BookSeries") : "" %></p>
                                    <p class="book-detail">
                                        <span>Author:</span><%# Eval("AuthorNames") %>
                                    </p>
                                    <p class="book-detail">
                                       <span style="text-decoration: underline;font-weight: bold;"> This Book Similiar To </span> 
                                        
                                    </p>
                                    <strong><%# Eval("SimilarTo").ToString().Replace("\n", " ").Replace("\r", " ").Trim() %></strong>
                                </div>
                                <div class="view-details-button-wrapper">
                                    <a href="BookDetail.aspx?bookid=<%# Eval("BookId") %>" class="view-details-button">View Details</a>
                                </div>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </asp:Panel>
            <!-- Message for when no books are available -->
            <div id="emptyMessage" runat="server" visible="false" class="empty-message">
                <p>No books at the moment.</p>
            </div>

        </div>

        <!-- Pagination -->
        <div class="pagination-container">
            <ul class="pagination-links">
                <li class="previous"><a href="#">Previous</a></li>
                <div class="pagination-numbers">
                    <ul class="pagination-numbers-list">
                    </ul>
                </div>
                <li class="next"><a href="#">Next</a></li>
            </ul>
        </div>
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
    <script src="assets/js/main.js"></script>
    <script src="assets/js/pagination.js"></script>
    <script src="assets/js/bootstrap.min.js"></script>
</asp:Content>


<%@ Page Title="" Language="C#" MasterPageFile="~/Master/Client.Master" AutoEventWireup="true" CodeBehind="BookSearch.aspx.cs" Inherits="fyp.BookSearch" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Search Book
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=no" />
    <link rel="stylesheet" href="assets/css/main.css" />
    <link rel="stylesheet" href="assets/css/bookSearch.css" />
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    <div class="search-bar-container">
        <form class="search-form" runat="server">
            <asp:TextBox runat="server" ID="tbSearch" placeholder="Search here..."></asp:TextBox>
            <asp:Button runat="server" Text="Search" ID="btnSearch" OnClick="Page_Load" />
        </form>
        <small style="font-size: .9286rem;">Search Tips ::<asp:HyperLink ID="btnAdvanceSearch" runat="server" Style="border: none; color: #2b74a9;" NavigateUrl="~/AdvancedSearch.aspx">Advanced Search</asp:HyperLink></small>
    </div>
                <div class="book-item-container">
                                <!-- Repeat similar structure for each book item, or dynamically generate -->
            <asp:Panel ID="pnlBooks" runat="server">
            <asp:Repeater ID="rptBooks" runat="server" OnItemDataBound="rptBooks_ItemDataBound" OnPreRender="rptBooks_PreRender">
                <ItemTemplate>
                    <div class="book-item">
                <div class="book-details">
                    <div class="book-image">
                        <%--<img src='<%# Eval("BookImage") %>' alt="Book Cover">--%>
                        <asp:Image ID="imageBook" runat="server"
                                ImageUrl='<%# Eval("BookImage") != DBNull.Value ? Eval("BookImage") : "images/defaultCoverBook.png" %>'
                                AlternateText="Book Cover" />
                    </div>
                   <div class="book-info">
                    <a href="BookDetail.aspx">
                        <h2 class="book-title"><%# Eval("BookTitle") %></h2>
                    </a>
                    <p class="book-detail"><span>Category: </span><%# Eval("CategoryNames") %></p>
                    <p class="book-detail"><%# !String.IsNullOrEmpty(Eval("BookSeries")?.ToString()) ? "<span>Series:</span> " + Eval("BookSeries") : "" %></p>
                    <p class="book-detail"><span>Author:</span> 
                        <asp:Repeater ID="rptAuthors" runat="server">
    <ItemTemplate>
        <span><%# Eval("AuthorName") %></span>
    </ItemTemplate>
</asp:Repeater>
                    </p>
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
    <p>No books here.</p>
</div>

                </div>
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
</asp:Content>
<asp:Content ID="Content4" ContentPlaceHolderID="ScriptContent" runat="server">
        <!-- Scripts -->

    <script src="assets/js/jquery.dropotron.min.js"></script>
    <script src="assets/js/jquery.scrolly.min.js"></script>
    <script src="assets/js/jquery.scrollex.min.js"></script>
    <script src="assets/js/browser.min.js"></script>
    <script src="assets/js/breakpoints.min.js"></script>
    <script src="assets/js/util.js"></script>
    <script src="assets/js/main.js"></script>
    <script src="assets/js/pagination.js"></script>
</asp:Content>

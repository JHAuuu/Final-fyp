<%@ Page Title="Dashboard" Language="C#" MasterPageFile="~/Master/DashMasterPage.Master" AutoEventWireup="true" CodeBehind="DashManagement.aspx.cs" Inherits="fyp.DashManagement" %>

<asp:Content ID="content1" ContentPlaceHolderID="MainContent" runat="server">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/flatpickr.min.css">
    <script src="https://cdn.jsdelivr.net/npm/flatpickr"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script><%--for draw diagram--%>
    <style>
        .card {
            background-color: #ffffff;
            padding: 20px;
            margin: 20px 0;
            border-radius: 8px;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
            transition: all 0.3s ease;
        }

            .card:hover {
                box-shadow: 0 6px 12px rgba(0, 0, 0, 0.2);
                transform: translateY(-5px);
            }

            .card h2 {
                font-size: 24px;
                margin: 0 0 10px 0;
                color: #333;
                font-weight: 600;
            }

            .card p {
                font-size: 16px;
                color: #555;
                line-height: 1.6;
            }

        .dateRangeSection {
            margin: 20px 0;
            display: flex;
            flex-direction: column;
            gap: 10px;
        }

            .dateRangeSection label {
                font-size: 14px;
                font-weight: 500;
                color: #555;
            }

            .dateRangeSection input[type="date"] {
                padding: 10px;
                font-size: 16px;
                border: 1px solid #ccc;
                border-radius: 4px;
                width: 100%;
                max-width: 250px;
                background-color: #f8f9fa;
            }

                .dateRangeSection input[type="date"]:hover {
                    border-color: #007bff;
                }

        .btn {
            padding: 10px 20px;
            border-radius: 4px;
            font-size: 16px;
            cursor: pointer;
            border: none;
            transition: background-color 0.3s ease;
            display: inline-block;
            text-align: center;
            width: auto;
        }

        .btn-primary {
            background-color: #007bff;
            color: white;
        }

            .btn-primary:hover {
                background-color: #0056b3;
                box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
            }

        .btn-secondary {
            background-color: #6c757d;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
            color: white;
        }

            .btn-secondary:hover {
                background-color: #5a6268;
            }

        button:disabled {
            background-color: #ccc;
            cursor: not-allowed;
        }

        .dashboard {
            display: flex;
            height: 110px;
            gap: 20px;
        }

        .card1 {
            width: 33%;
            height: 100%;
            padding: 10px 15px;
            color: white;
            border-radius: 5px;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.2);
            position: relative;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            background-color: #8390A2;
        }

            .card1 .number {
                font-size: 20px;
                font-weight: 600;
                margin-bottom: 2px;
            }

            .card1 .label {
                font-size: 16px;
                margin-bottom: 2px;
            }

            .card1 .icon {
                font-size: 40px;
                opacity: 0.3;
                position: absolute;
                top: 5px;
                right: 10px;
            }

            .card1 .more-info {
                display: flex;
                justify-content: space-between;
                align-items: center;
                padding: 3px 5px;
                background-color: rgba(0, 0, 0, 0.1); /* Light background color */
                border-radius: 3px;
                transition: background-color 0.3s;
                cursor: pointer;
            }

                .card1 .more-info:hover {
                    background-color: rgba(0, 0, 0, 0.2); /* Darker background on hover */
                }

        .date-picker {
            padding: 10px;
            font-size: 16px;
            border: 1px solid #ccc;
            border-radius: 4px;
            width: 100%;
            max-width: 250px;
        }

        .flatpickr-day.available {
            background-color: green !important;
            color: white !important;
            border-radius: 50%; /* Optional: Circular highlight */
        }

        /* Ensure this only targets input elements of type submit (buttons) */
        input[type="submit"][disabled] {
            background-color: #e0e0e0; /* Light gray background */
            color: #a0a0a0; /* Gray text */
            cursor: not-allowed; /* Show not-allowed cursor */
            border: 1px solid #d0d0d0; /* Optional: Light border */
            opacity: 0.7; /* Slight transparency */
            box-shadow: none; /* Remove shadow for a flat look */
        }

        /* Optional: Add hover effect for enabled buttons */
        input[type="submit"]:not([disabled]):hover {
            background-color: #0056b3; /* Darker blue for primary buttons */
        }

        body.dark-mode {
            background-color: #121212;
            color: #e0e0e0;
        }

            /* Dark Mode Styling for the Card */
            body.dark-mode .card {
                background-color: #2c2c2c;
                color: #e0e0e0;
                box-shadow: 0 4px 8px rgba(0, 0, 0, 0.5);
            }

                /* Font Styling for Headings and Text */
                body.dark-mode .card h2 {
                    color: #ffffff; /* White for headings */
                }

                body.dark-mode .card p {
                    color: #cccccc; /* Light grey for descriptive text */
                }

            /* Styling for Labels */
            body.dark-mode .dateRangeSection label {
                color: #e0e0e0; /* Light grey for labels */
            }

            /* Styling for Inputs in Dark Mode */
            body.dark-mode .dateRangeSection input[type="date"] {
                background-color: #3a3a3a;
                color: #e0e0e0;
                border: 1px solid #555555;
                border-radius: 4px;
            }

                body.dark-mode .dateRangeSection input[type="date"]:hover {
                    border-color: #777777; /* Slightly brighter border on hover */
                }

            /* Styling for Buttons */
            body.dark-mode .btn-primary {
                background-color: #1a73e8;
                color: white;
            }

                body.dark-mode .btn-primary:hover {
                    background-color: #1669c7;
                }

            body.dark-mode .btn-secondary {
                background-color: #5a6268;
                color: white;
            }

                body.dark-mode .btn-secondary:hover {
                    background-color: #495057;
                }

            /* Disabled Button Styling */
            body.dark-mode input[type="submit"]:disabled {
                background-color: #444444;
                color: #888888;
                cursor: not-allowed;
            }

            /* Optional Hover Effect for Non-Disabled Buttons */
            body.dark-mode input[type="submit"]:not(:disabled):hover {
                box-shadow: 0 4px 8px rgba(0, 0, 0, 0.3);
            }

            body.dark-mode .card1 {
                background-color: #2c2c2c; /* Darker background for dark mode */
                color: #e0e0e0;
                box-shadow: 0 4px 8px rgba(0, 0, 0, 0.5);
            }

                body.dark-mode .card1 .number {
                    color: #f5f5f5;
                }

                body.dark-mode .card1 .label {
                    color: #b0b0b0;
                }

                body.dark-mode .card1 .more-info {
                    background-color: rgba(255, 255, 255, 0.1);
                    color: #e0e0e0;
                }

                    body.dark-mode .card1 .more-info:hover {
                        background-color: rgba(255, 255, 255, 0.2);
                        color: #ffffff;
                    }

                    .charts-container {
        margin: 20px 0;
        display: flex;
        flex-direction: column;
        gap: 20px;
    }

    .charts-container canvas {
        box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
        border-radius: 8px;
        background-color: white;
    }
    </style>
    <div class="dashboard">
        <div class="card1">
            <asp:Label ID="lblStaffNum" runat="server" class="number"></asp:Label>
            <div class="label">Library Staff</div>
            <div class="icon"><i class="las la-user-tie"></i></div>
            <a class="more-info" href="StaffManagement.aspx">
                <span style="color: white;">More info</span>
                <span style="color: white;">➔</span>
            </a>
        </div>
        <div class="card1">
            <asp:Label ID="lblUserNum" runat="server" class="number"></asp:Label>
            <div class="label">User</div>
            <div class="icon"><i class="las la-users"></i></div>
            <a class="more-info" href="UsersManagement.aspx">
                <span style="color: white;">More info</span>
                <span style="color: white;">➔</span>
            </a>
        </div>
        <div class="card1">
            <asp:Label ID="lblBookNum" runat="server" class="number"></asp:Label>
            <div class="label">Book</div>
            <div class="icon"><i class="las la-book"></i></div>
            <a class="more-info" href="BookManagement.aspx">
                <span style="color: white;">More info</span>
                <span style="color: white;">➔</span>
            </a>
        </div>

    </div>
    <div class="charts-container">
    <div style="width: 100%; margin-bottom: 20px;">
        <canvas id="booksBorrowedChart"></canvas>
    </div>
    <div style="display: flex; gap: 20px;">
        <div style="flex: 1;">
            <canvas id="mostBorrowedBooksChart"></canvas>
        </div>
        <div style="flex: 1;">
            <canvas id="userActivityChart"></canvas>
        </div>
    </div>
</div>


    <div class="card" id="borrowedReport">
        <h2>Book Borrowed Report</h2>
        <p>Here you can view the report of all the borrowed books.</p>

        <!-- Time Range Selection (Initially Hidden) -->
        <div class="dateRangeSection">
            <label for="startDate">Start Date:</label>
            <asp:TextBox ID="txtStartDate" runat="server" TextMode="Date" CssClass="date-picker" />

            <label for="endDate">End Date:</label>
            <asp:TextBox ID="txtEndDate" runat="server" TextMode="Date" CssClass="date-picker" />
        </div>

        <div>
            <asp:Button ID="btnGenerateReport" runat="server" Text="Generate Report" CssClass="btn btn-primary" OnClick="btnGenerateReport_Click"/>
            <asp:Button ID="btnViewBorrow" runat="server" Text="View Report" CssClass="btn btn-secondary" OnClick="btnViewBorrow_Click" />
        </div>
    </div>

    <div class="card" id="addedReport">
        <h2>Book Added Report</h2>
        <p>Here you can view the report of all the newly added books.</p>
        <div class="dateRangeSection">
            <label for="startDate">Start Date:</label>
            <asp:TextBox ID="txtBookStartDate" runat="server" TextMode="Date" CssClass="date-picker" />

            <label for="endDate">End Date:</label>
            <asp:TextBox ID="txtBookEndDate" runat="server" TextMode="Date" CssClass="date-picker" />
        </div>

        <div>
            <asp:Button ID="btnGenerateAddBook" runat="server" Text="Generate Report" CssClass="btn btn-primary" OnClick="btnGenerateAddBook_Click"/>
            <asp:Button ID="btnViewAddBook" runat="server" Text="View Report" CssClass="btn btn-secondary" OnClick="btnViewAddBook_Click" />
        </div>
    </div>
    <script>
        window.controlIDs = {
            txtStartDate: '<%= txtStartDate.ClientID %>',
            txtBookStartDate: '<%= txtBookStartDate.ClientID %>',
            txtEndDate: '<%= txtEndDate.ClientID %>',
            txtBookEndDate: '<%= txtBookEndDate.ClientID %>',
        btnGenerateReport: '<%= btnGenerateReport.ClientID %>',
        btnViewBorrow: '<%= btnViewBorrow.ClientID %>',
        btnGenerateAddBook: '<%= btnGenerateAddBook.ClientID %>',
            btnViewAddBook: '<%= btnViewAddBook.ClientID %>'
        };

        document.addEventListener("DOMContentLoaded", function () {
            const booksBorrowedChartConfig = {
                type: "line",
                data: {
                    labels: [], // Placeholder, updated dynamically
                    datasets: [{
                        label: "Books Borrowed",
                        data: [], // Placeholder, updated dynamically
                        backgroundColor: "rgba(75, 192, 192, 0.5)",
                        borderColor: "rgba(75, 192, 192, 1)",
                        borderWidth: 1,
                    }]
                },
                options: {
                    responsive: true,
                    plugins: {
                        legend: { display: true, position: "top" }
                    }
                }
            };

            const ctxBorrowed = document.getElementById("booksBorrowedChart").getContext("2d");
            const booksBorrowedChart = new Chart(ctxBorrowed, booksBorrowedChartConfig);

            // Fetch data from the server
            fetchData();

            function fetchData() {
                $.ajax({
                    type: "POST",
                    url: "DashManagement.aspx/GetBooksBorrowedData",
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        const data = response.d; // Extract data from the response

                        // Update the chart
                        booksBorrowedChartConfig.data.labels = data.months;
                        booksBorrowedChartConfig.data.datasets[0].data = data.borrowedBooks;
                        booksBorrowedChart.update();
                    },
                    error: function (xhr, status, error) {
                        console.error("Error fetching data:", error);
                    }
                });
            }
        });

        document.addEventListener("DOMContentLoaded", function () {
            const ctxMostBorrowed = document.getElementById("mostBorrowedBooksChart").getContext("2d");

            fetchMostBorrowedBooksData();

            function fetchMostBorrowedBooksData() {
                $.ajax({
                    type: "POST",
                    url: "DashManagement.aspx/GetMostBorrowedBooksByCategory",
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        const data = response.d; // Extract data from the response

                        // Prepare data for the pie chart
                        const mostBorrowedBooksData = {
                            labels: data.categories,
                            datasets: [{
                                data: data.counts,
                                backgroundColor: generateRandomColors(data.categories.length),
                                hoverBackgroundColor: generateRandomColors(data.categories.length)
                            }]
                        };

                        // Initialize the chart
                        new Chart(ctxMostBorrowed, {
                            type: "pie",
                            data: mostBorrowedBooksData,
                            options: {
                                responsive: true,
                                plugins: {
                                    legend: { display: true, position: "right" }
                                }
                            }
                        });
                    },
                    error: function (xhr, status, error) {
                        console.error("Error fetching most borrowed books data:", error);
                    }
                });
            }

            function generateRandomColors(count) {
                const colors = [];
                for (let i = 0; i < count; i++) {
                    colors.push(`hsl(${Math.floor(Math.random() * 360)}, 70%, 60%)`);
                }
                return colors;
            }
        });

        document.addEventListener("DOMContentLoaded", function () {
            const ctxUserActivity = document.getElementById("userActivityChart").getContext("2d");

            // Fetch user activity data
            fetchUserActivityData();

            function fetchUserActivityData() {
                $.ajax({
                    type: "POST",
                    url: "DashManagement.aspx/GetUserActivityData",
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        const data = response.d; // Extract data from the response

                        const userActivityData = {
                            labels: data.months,
                            datasets: [{
                                label: "New Users",
                                data: data.counts,
                                backgroundColor: "rgba(153, 102, 255, 0.5)",
                                borderColor: "rgba(153, 102, 255, 1)",
                                borderWidth: 1,
                            }]
                        };

                        // Initialize the chart
                        new Chart(ctxUserActivity, {
                            type: "bar",
                            data: userActivityData,
                            options: {
                                responsive: true,
                                plugins: {
                                    legend: { display: true, position: "top" }
                                },
                                scales: {
                                    y: { beginAtZero: true }
                                }
                            }
                        });
                    },
                    error: function (xhr, status, error) {
                        console.error("Error fetching user activity data:", error);
                    }
                });
            }
        });
    </script>
    <script src="assets/js/dashManagement.js"></script>
</asp:Content>

window.onload = function () {
    // Access control IDs from the global object
    const controlIDs = window.controlIDs;

    // Use these IDs to get the elements
    const txtStartDate = document.getElementById(controlIDs.txtStartDate);
    const txtBookStartDate = document.getElementById(controlIDs.txtBookStartDate);
    const txtEndDate = document.getElementById(controlIDs.txtEndDate);
    const txtBookEndDate = document.getElementById(controlIDs.txtBookEndDate);

    const btnGenerateReport = document.getElementById(controlIDs.btnGenerateReport);
    const btnViewBorrow = document.getElementById(controlIDs.btnViewBorrow);
    const btnGenerateAddBook = document.getElementById(controlIDs.btnGenerateAddBook);
    const btnViewAddBook = document.getElementById(controlIDs.btnViewAddBook);

    const today = new Date();
    const formattedDate = today.toISOString().split('T')[0]; // Get the date in YYYY-MM-DD format

    // Disable the Generate Report button initially
    btnGenerateReport.disabled = true;
    btnViewBorrow.disabled = true;
    btnGenerateAddBook.disabled = true;
    btnViewAddBook.disabled = true;

    txtStartDate.addEventListener('change', function () {
        // Enable the Generate Report button only if the start date is selected
        btnGenerateReport.disabled = !this.value;
        btnViewBorrow.disabled = !this.value;
    });

    txtBookStartDate.addEventListener('change', function () {
        // Enable the Generate Report button only if the start date is selected
        btnGenerateAddBook.disabled = !this.value;
        btnViewAddBook.disabled = !this.value;
    });

    // Apply Flatpickr for Borrowed Report
    const borrowedDatesSet = new Set(borrowedDates);
    const startFlatpickr = applyFlatpickr(`#${controlIDs.txtStartDate}`, borrowedDatesSet);
    let endFlatpickr = applyFlatpickr(`#${controlIDs.txtEndDate}`, borrowedDatesSet);

    // Apply Flatpickr for Added Report
    const addedDatesSet = new Set(addedDates);
    const bookStartFlatpickr = applyFlatpickr(`#${controlIDs.txtBookStartDate}`, addedDatesSet);
    let bookEndFlatpickr = applyFlatpickr(`#${controlIDs.txtBookEndDate}`, addedDatesSet);


    // Add onchange event listener for the Borrowed Start Date field
    document.getElementById(controlIDs.txtStartDate).addEventListener("change", function () {
        const startDate = this.value;
        if (startDate) {
            // Enable the end date field and update Flatpickr for End Date
            updateEndDateFlatpickr(endFlatpickr, startDate);
        }
    });

    // Add onchange event listener for the Added Start Date field
    document.getElementById(controlIDs.txtBookStartDate).addEventListener("change", function () {
        const startDate = this.value;
        if (startDate) {
            // Enable the end date field and update Flatpickr for End Date
            updateEndDateFlatpickr(bookEndFlatpickr, startDate);
        }
    });

    // Function to update Flatpickr configuration for End Date
    function updateEndDateFlatpickr(flatpickrInstance, minDate) {
        flatpickrInstance.set("minDate", minDate); // Update the minimum date for the Flatpickr instance
        const endField = flatpickrInstance.input;
        if (endField.value && new Date(endField.value) < new Date(minDate)) {
            endField.value = ""; // Clear the value if it doesn't meet the new minimum date
        }
    }

    // Function to apply Flatpickr
    function applyFlatpickr(selector, availableDatesSet) {
        return flatpickr(selector, {
            dateFormat: "Y-m-d",
            enable: [...availableDatesSet].map(date => new Date(date)), // Enable only available dates
            onDayCreate: function (dObj, dStr, fp, dayElem) {
                const date = dayElem.dateObj.toLocaleDateString("en-CA"); // Format as YYYY-MM-DD
                if (availableDatesSet.has(date)) {
                    dayElem.classList.add("available"); // Add green highlight
                } else {
                    dayElem.classList.remove("available"); // Remove highlight if not available
                }
            },
            onChange: function (selectedDates, dateStr) {
                if (!availableDatesSet.has(dateStr)) {
                    this.clear(); // Clear invalid input
                    console.log("Invalid selection: No data available for the selected date.");
                }
            },
            onClose: function (selectedDates, dateStr) {
                if (!availableDatesSet.has(dateStr) && dateStr) {
                    this.clear(); // Clear invalid input
                    alert("This date has no data available."); // Alert shown only once when closing
                }
            }
        });
    }
};
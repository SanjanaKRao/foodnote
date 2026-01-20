import SwiftUI

struct DatePickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedStartDate: Date?
    @Binding var selectedEndDate: Date?
    @Binding var isSelectingRange: Bool
    
    @State private var tempStartDate: Date = Date()
    @State private var tempEndDate: Date = Date()
    
    init(selectedStartDate: Binding<Date?>, selectedEndDate: Binding<Date?>, isSelectingRange: Binding<Bool>) {
        self._selectedStartDate = selectedStartDate
        self._selectedEndDate = selectedEndDate
        self._isSelectingRange = isSelectingRange
        
        // Initialize with existing dates or today
        let startDate = selectedStartDate.wrappedValue ?? Date()
        let endDate = selectedEndDate.wrappedValue ?? Date()
        
        // Ensure end is not before start
        if endDate < startDate {
            _tempStartDate = State(initialValue: startDate)
            _tempEndDate = State(initialValue: startDate)
        } else {
            _tempStartDate = State(initialValue: startDate)
            _tempEndDate = State(initialValue: endDate)
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Toggle for single date vs range
                    Picker("Selection Type", selection: $isSelectingRange) {
                        Text("Single Day").tag(false)
                        Text("Date Range").tag(true)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    .onChange(of: isSelectingRange) {
                        // Reset to today when switching modes
                        let today = Date()
                        tempStartDate = today
                        tempEndDate = today
                    }
                    
                    if isSelectingRange {
                        // Range mode - two date pickers
                        VStack(alignment: .leading, spacing: 16) {
                            // Start date
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Start Date")
                                    .font(.headline)
                                    .padding(.horizontal)
                                
                                DatePicker(
                                    "",
                                    selection: Binding(
                                        get: { tempStartDate },
                                        set: { newValue in
                                            tempStartDate = newValue
                                            // Ensure end date is not before start date
                                            if tempEndDate < newValue {
                                                tempEndDate = newValue
                                            }
                                        }
                                    ),
                                    displayedComponents: .date
                                )
                                .datePickerStyle(.graphical)
                                .padding(.horizontal)
                            }
                            
                            Divider()
                                .padding(.vertical, 8)
                            
                            // End date
                            VStack(alignment: .leading, spacing: 8) {
                                Text("End Date")
                                    .font(.headline)
                                    .padding(.horizontal)
                                
                                DatePicker(
                                    "",
                                    selection: Binding(
                                        get: { tempEndDate },
                                        set: { newValue in
                                            // Ensure end date is not before start date
                                            if newValue >= tempStartDate {
                                                tempEndDate = newValue
                                            }
                                        }
                                    ),
                                    displayedComponents: .date
                                )
                                .datePickerStyle(.graphical)
                                .padding(.horizontal)
                            }
                        }
                    } else {
                        // Single date mode - one date picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Select Date")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            DatePicker(
                                "",
                                selection: $tempStartDate,
                                displayedComponents: .date
                            )
                            .datePickerStyle(.graphical)
                            .padding(.horizontal)
                        }
                    }
                    
                    // Summary of selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Selected:")
                            .font(.headline)
                        
                        HStack {
                            Label(formatDate(tempStartDate), systemImage: "calendar")
                                .font(.subheadline)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(8)
                            
                            if isSelectingRange && tempStartDate != tempEndDate {
                                Image(systemName: "arrow.right")
                                    .font(.caption)
                                    .foregroundStyle(.gray)
                                
                                Label(formatDate(tempEndDate), systemImage: "calendar")
                                    .font(.subheadline)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(8)
                            }
                            
                            Spacer()
                        }
                        
                        if isSelectingRange {
                            let days = Calendar.current.dateComponents([.day], from: tempStartDate, to: tempEndDate).day ?? 0
                            Text("\(days + 1) day\(days == 0 ? "" : "s")")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Select Date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") {
                        applyDateFilter()
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func applyDateFilter() {
        selectedStartDate = tempStartDate
        if isSelectingRange {
            selectedEndDate = tempEndDate
        } else {
            selectedEndDate = nil
        }
    }
}

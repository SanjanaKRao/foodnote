import SwiftUI

struct CountryDetailView: View {
    let country: String
    let images: [StoredImage]
    let notes: [String: FoodNote]
    @Binding var selectedImage: StoredImage?
    @Binding var pendingUIImage: UIImage?
    @Binding var showAddNote: Bool
    @Binding var errorMessage: String?
    let deleteImage: (StoredImage) -> Void
    let foodCard: (StoredImage) -> AnyView
    
    @Environment(\.dismiss) private var dismiss
    @State private var showImageDetail = false
    @State private var imageDetailData: (image: UIImage, note: FoodNote?)? = nil
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 16)], spacing: 20) {
                    ForEach(images) { img in
                        simpleCard(for: img)
                    }
                }
                .padding()
            }
            .background(Color.white)
            .navigationTitle(country)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .fullScreenCover(isPresented: $showImageDetail) {
                // Use fullScreenCover instead of sheet
                if let data = imageDetailData {
                    ImageDetailView(
                        image: data.image,
                        note: data.note
                    ) {
                        showImageDetail = false
                        dismiss()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            showAddNote = true
                        }
                    }
                } else {
                    // Fallback
                    Color.black
                        .ignoresSafeArea()
                        .onAppear {
                            print("❌ imageDetailData is nil!")
                        }
                }
            }
        }
    }
    
    func simpleCard(for img: StoredImage) -> some View {
        Group {
            if let uiImage = UIImage(contentsOfFile: img.fileURL.path) {
                NavigationLink {
                    ImageDetailView(
                        image: uiImage,
                        note: notes[img.id]
                    ) {
                        // Edit action
                        selectedImage = img
                        pendingUIImage = uiImage
                        dismiss()  // Dismiss country view
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            showAddNote = true
                        }
                    }
                } label: {
                    VStack(alignment: .leading, spacing: 8) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 160, height: 160)
                            .clipped()
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        
                        noteInfoView(for: img)
                            .frame(width: 160, alignment: .leading)
                            .padding(.horizontal, 4)
                    }
                    .background(Color.white)
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    func noteInfoView(for img: StoredImage) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            if let note = notes[img.id] {
                Text(note.name)
                    .font(.system(size: 16, weight: .semibold))
                    .lineLimit(1)
                    .foregroundStyle(Color(red: 0, green: 0, blue: 0))
                
                if !note.restaurant.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "fork.knife")
                            .font(.system(size: 10))
                            .foregroundStyle(Color(red: 0, green: 0, blue: 0))
                        Text(note.restaurant)
                            .font(.system(size: 12))
                            .foregroundStyle(Color(red: 0, green: 0, blue: 0))
                            .lineLimit(1)
                    }
                }
                
                if !note.location.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(Color(red: 0, green: 0, blue: 0))
                        Text(note.location)
                            .font(.system(size: 12))
                            .foregroundStyle(Color(red: 0, green: 0, blue: 0))
                            .lineLimit(1)
                    }
                }
                
                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { star in
                        Image(systemName: star <= note.rating ? "star.fill" : "star")
                            .font(.system(size: 10))
                            .foregroundStyle(star <= note.rating ? Color.yellow : Color(red: 0, green: 0, blue: 0))
                    }
                }
                
                if !note.description.isEmpty {
                    Text(note.description)
                        .font(.system(size: 12))
                        .foregroundStyle(Color(red: 0, green: 0, blue: 0))
                        .lineLimit(2)
                        .padding(.top, 2)
                }
            } else {
                Text("Tap to add note")
                    .font(.system(size: 12))
                    .foregroundStyle(.gray.opacity(0.7))
                    .italic()
            }
        }
    }
}

import SwiftUI

struct ImageDetailView: View {
    let image: UIImage
    let note: FoodNote?
    let onEditNote: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Zoomable Image
                    GeometryReader { geometry in
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .scaleEffect(scale)
                            .offset(offset)
                            .gesture(
                                MagnificationGesture()
                                    .onChanged { value in
                                        let delta = value / lastScale
                                        lastScale = value
                                        scale = min(max(scale * delta, 1), 5) // Min 1x, Max 5x zoom
                                    }
                                    .onEnded { _ in
                                        lastScale = 1.0
                                        
                                        // Reset if zoomed out completely
                                        if scale <= 1 {
                                            withAnimation(.spring()) {
                                                scale = 1
                                                offset = .zero
                                            }
                                        }
                                    }
                            )
                            .simultaneousGesture(
                                DragGesture()
                                    .onChanged { value in
                                        // Only allow dragging when zoomed in
                                        if scale > 1 {
                                            offset = CGSize(
                                                width: lastOffset.width + value.translation.width,
                                                height: lastOffset.height + value.translation.height
                                            )
                                        }
                                    }
                                    .onEnded { _ in
                                        lastOffset = offset
                                    }
                            )
                            .onTapGesture(count: 2) {
                                // Double tap to zoom in/out
                                withAnimation(.spring()) {
                                    if scale > 1 {
                                        scale = 1
                                        offset = .zero
                                        lastOffset = .zero
                                    } else {
                                        scale = 2
                                    }
                                }
                            }
                    }
                    
                    // Note info at bottom (only visible when not zoomed)
                    if let note = note, scale <= 1.2 {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(note.name)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundStyle(.white)
                                    
                                    if !note.restaurant.isEmpty {
                                        HStack(spacing: 6) {
                                            Image(systemName: "fork.knife")
                                                .font(.subheadline)
                                            Text(note.restaurant)
                                                .font(.subheadline)
                                        }
                                        .foregroundStyle(.white.opacity(0.9))
                                    }
                                    
                                    if !note.location.isEmpty {
                                        HStack(spacing: 6) {
                                            Image(systemName: "mappin.circle.fill")
                                                .font(.subheadline)
                                            Text(note.location)
                                                .font(.subheadline)
                                        }
                                        .foregroundStyle(.white.opacity(0.9))
                                    }
                                    
                                    HStack(spacing: 4) {
                                        ForEach(1...5, id: \.self) { star in
                                            Image(systemName: star <= note.rating ? "star.fill" : "star")
                                                .font(.subheadline)
                                                .foregroundStyle(star <= note.rating ? .yellow : .white.opacity(0.5))
                                        }
                                    }
                                    
                                    if !note.description.isEmpty {
                                        Text(note.description)
                                            .font(.body)
                                            .foregroundStyle(.white.opacity(0.9))
                                            .padding(.top, 4)
                                    }
                                }
                                
                                Spacer()
                            }
                            .padding()
                            .background(.ultraThinMaterial.opacity(0.9))
                            .cornerRadius(16)
                            .padding()
                            .onTapGesture {
                                onEditNote()
                            }
                        }
                        .transition(.move(edge: .bottom))
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(.white)
                            .font(.headline)
                    }
                }
                
                if note != nil {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            onEditNote()
                        } label: {
                            Image(systemName: "pencil")
                                .foregroundStyle(.white)
                                .font(.headline)
                        }
                    }
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
        }
    }
}

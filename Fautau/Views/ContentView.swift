//
//  ContentView.swift
//  Fautau
//
//  Created by Florentin BEKIER on 14/06/2021.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject private var photoImportHelper = PhotoImportHelper()

    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertTitle = Text("Alert")
    @State private var alertMessage: Text?
    @State private var showHelp = false

    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                VStack(spacing: 16.0) {
                    Text("\(photoImportHelper.photosCount) images found")
                    Button(action: importImages) {
                        Image(systemName: "square.and.arrow.down")
                        Text("Bulk import")
                    }
                    .disabled(isLoading)
                }
                .font(.title)
            }
            .navigationBarTitle("Fautau")
            .navigationBarItems(leading: Button(action: {
                showHelp = true
            }, label: {
                Image(systemName: "questionmark.circle")
                    .barIcon(label: "Help")
            }), trailing: HStack {
                Button(action: photoImportHelper.openDocumentDirectory) {
                    Image(systemName: "folder")
                        .barIcon(label: "Go to folder")
                }
                .padding()
                Button(action: fetchImages) {
                    Image(systemName: "arrow.clockwise")
                        .barIcon(label: "Reload")
                }
                .disabled(isLoading)
            })
        }
        .onAppear {
            fetchImages()
        }
        .alert(isPresented: $showAlert, content: {
            Alert(title: alertTitle, message: alertMessage, dismissButton: .cancel(Text("Dismiss")))
        })
        .sheet(isPresented: $showHelp, content: {
            HelpView(showHelp: $showHelp)
        })
    }

    private func fetchImages() {
        guard !isLoading else { return }
        isLoading = true
        photoImportHelper.fetchImages { success in
            isLoading = false
            if !success {
                alertTitle = Text("Error")
                alertMessage = Text("Failed to read images.")
                showAlert = true
            }
        }
    }

    private func importImages() {
        guard !isLoading else { return }
        isLoading = true
        photoImportHelper.importImages { success in
            isLoading = false
            alertTitle = Text(success ? "Import succeeded" : "Error")
            alertMessage = success ? nil : Text("Failed to import images.")
            showAlert = true
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

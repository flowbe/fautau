//
//  HelpView.swift
//  Fautau
//
//  Created by Florentin BEKIER on 14/06/2021.
//

import SwiftUI

struct HelpView: View {
    @Binding var showHelp: Bool

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Fautau helps you easily import a large number of images to your photo library.")
                    Text("First, move the images you want to import to the \"Fautau\" folder. You can do so using iTunes on your computer, or using the Files app on your device. Tap the \(Image(systemName: "folder")) icon on the main screen to locate the folder.")
                    Text("Then, all you have to do is reload and tap the \"Bulk import\" button to start importing your images.")
                    Text("Note: you should make sure that you granted the app access to your photo library for the import to work.")
                }
                .padding()
            }
            .navigationBarTitle("How it works")
            .navigationBarItems(trailing: Button("Done") {
                showHelp = false
            })
        }
    }
}

struct HelpView_Previews: PreviewProvider {
    static var previews: some View {
        HelpView(showHelp: .constant(true))
    }
}

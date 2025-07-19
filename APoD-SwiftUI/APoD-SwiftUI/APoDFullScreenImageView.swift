//
//  APoDFullScreenImageView.swift
//  APoD-SwiftUI
//
//  Created by Kuixi Song on 7/18/25.
//

import SwiftUI

struct APoDFullScreenImageView: View {

  @Environment(\.dismiss) var dismiss
  var imageURL: URL

  var body: some View {
    APoDImageView(imageURL: imageURL)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .backgroundStyle(.black)
      .overlay(alignment: .topLeading) {
        Button {
          dismiss()
        } label: {
          Image(systemName: "xmark")
        }
        .padding()
      }
  }

}

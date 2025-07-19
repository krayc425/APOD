//
//  File.swift
//  APoD-SwiftUI
//
//  Created by Kuixi Song on 7/18/25.
//

import SwiftUI

struct APoDImageView: View {

  var imageURL: URL

  var body: some View {
    AsyncImage(url: imageURL) { image in
      image.resizable().scaledToFit()
    } placeholder: {
      ProgressView()
    }
  }

}

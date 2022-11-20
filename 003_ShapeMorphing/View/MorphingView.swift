//
//  MorphingView.swift
//  003_ShapeMorphing
//
//  Created by nikita on 19.09.2022.
//

import SwiftUI

struct MorphingView: View {
	
	@State var currentImage: CustomShape = .cloud
	@State var pickerImage: CustomShape = .cloud
	@State var turnOffImageMorph: Bool = false
	@State var blurRadius: CGFloat = 0 
	@State var animateMorph: Bool = false
	
    var body: some View {
		VStack {
			
			GeometryReader { proxy in
				let size = proxy.size
				Image("love")
					.resizable()
					.aspectRatio(contentMode: .fill)
					.offset(x: 10, y: 0)
					.frame(width: size.width, height: size.height)
					.clipped()
					.overlay(content: {
						Rectangle()
							.fill(.white)
							.opacity(turnOffImageMorph ? 1 : 0)
					})
					.mask { 
						Canvas { context, size in
							context.addFilter(.alphaThreshold(min: 0.5))
							context.addFilter(.blur(radius: blurRadius >= 20 ? 20 - (blurRadius - 20) : blurRadius))
							
							context.drawLayer { ctx in
								if let resolvedImage = context.resolveSymbol(id: 1) {
									ctx.draw(resolvedImage, at: CGPoint(x: size.width / 2, y: size.height / 2	), anchor: .center)
								}
							}
						} symbols: {
							ResolvedImage(currentImage: $currentImage)
								.tag(1)
						}
						.onReceive(Timer.publish(every: 0.007, on: .main, in: .common).autoconnect()) { _ in
							
							if animateMorph {
								if blurRadius <= 40 {
									blurRadius += 0.5
									
									if blurRadius.rounded() == 20 {
										currentImage = pickerImage
									}
								}
								
								if blurRadius.rounded() == 40 {
									animateMorph = false
									blurRadius = 0
								}
							}
						}
					}
			}
			.frame(height: 400)
			
			Picker("", selection: $pickerImage) {
				ForEach(CustomShape.allCases, id: \.rawValue) { shape in
					Image(systemName: shape.rawValue)
						.tag(shape)
				}
			}
			.pickerStyle(.segmented)
			.overlay(content: { 
				Rectangle()
					.fill(.primary)
					.opacity(animateMorph ? 0.05 : 0)
			})
			.padding(15)
			.padding(.top, -50)
			.onChange(of: pickerImage) { newValue in
				animateMorph = true
			}
			
			Toggle("Turn Off Image Morph", isOn: $turnOffImageMorph)
				.fontWeight(.semibold)
				.padding(.horizontal, 15)
				.padding(.top, 10)
		}
		.offset(y: -50)
		.frame(maxHeight: .infinity, alignment: .top)
    }
}

struct ResolvedImage: View {
	
	@Binding var currentImage: CustomShape
	
	var body: some View {
		Image(systemName: currentImage.rawValue)
			.font(.system(size: 200))
			.animation(.interactiveSpring(response: 0.7, dampingFraction: 0.8, blendDuration: 0.8), value: currentImage)
			.frame(width: 300, height: 300)
	}
	
}

struct MorphingView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

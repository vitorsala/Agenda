//
//  LoadingView.swift
//  Agenda
//
//  Created by Vitor Kawai Sala on 10/06/15.
//  Copyright (c) 2015 Melhor Grupo. All rights reserved.
//

import Foundation
import UIKit

class LoadingView : UIView{
}

@IBDesignable
class InternalLoadingView : UIView{
	@IBInspectable var cornerRadius : CGFloat {
		get{
			return self.layer.cornerRadius
		}
		set{
			self.layer.cornerRadius = newValue
			self.layer.masksToBounds = (newValue > 0)
		}
	}
}

@IBDesignable
class ActivityIndicator : UIActivityIndicatorView{

	var _scaleMultiplier : CGFloat = 0.0

	@IBInspectable var scaleMultiplier: CGFloat {
		get{
			return _scaleMultiplier
		}
		set{
			_scaleMultiplier = newValue
			self.transform = CGAffineTransformMakeScale(_scaleMultiplier, _scaleMultiplier)
		}
	}
}
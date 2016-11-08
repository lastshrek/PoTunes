//
//  ConfigurationBlock.swift
//  破音万里
//
//  Created by Purchas on 16/8/22.
//  Copyright © 2016年 Purchas. All rights reserved.
//

import Foundation
@warn_unused_result
internal func Init<Type>(_ value : Type, @noescape block: (object: Type) -> Void) -> Type
{
	block(object: value)
	return value
}

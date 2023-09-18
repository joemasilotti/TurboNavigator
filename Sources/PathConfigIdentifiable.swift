//
//  PathConfigIdentifiable.swift
//  Calendar
//
//  Created by Fernando Olivares on 11/09/23.
//

import UIKit

/// A covenient way to identify view controllers.
public protocol PathConfigViewControllerIdentifiable : UIViewController {
    static var viewControllerPathConfigIdentifier: String { get }
}

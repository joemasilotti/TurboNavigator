//
//  File 2.swift
//  
//
//  Created by Fernando Olivares on 01/11/23.
//

import Foundation
import Turbo

class TurboNavigator {
    
    let session: Session
    let modalSession: Session
    let hierarchyController: TurboNavigationHierarchyController
    init(session: Session, modalSession: Session, hierarchyController: TurboNavigationHierarchyController) {
        self.session = session
        self.modalSession = modalSession
        self.hierarchyController = hierarchyController
    }
    
    func route(url: URL) {
        let options = VisitOptions(action: .advance, response: nil)
        let properties = session.pathConfiguration?.properties(for: url) ?? PathProperties()
        let proposal = VisitProposal(url: url, options: options, properties: properties)
        hierarchyController.route(proposal)
    }
}

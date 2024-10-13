//
//  NavigationData.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 13/10/2024.
//

import SwiftUI

/// Allows handling navigation
struct NavigationData<RouterType: RouterProtocol, each Content: ViewDataProtocol>: ViewDataProtocol {
    typealias ContentView = NavigationView<repeat each Content>
    let values: (repeat each Content)
    let navigationPath: Binding<NavigationPath>
    let router: RouterType
    
    init(
        router: RouterType,
        navigationPath: Binding<NavigationPath>,
        @FringeDataResultBuilder _ data: () -> (repeat each Content)
    ) {
        self.navigationPath = navigationPath
        self.values = data()
        self.router = router
    }
    
    struct NavigationView<each T: ViewDataProtocol>: View, ViewProtocol {
        let data: NavigationData<RouterType, repeat each T>
        
        var body: some View {
            NavigationStack(path: data.navigationPath) {
                content
                    .navigationDestination(for: RouterType.NavigationLocation.self,
                                           destination: { $0.toView() })
            }
        }
        
        private var content: some View {
            TupleView((repeat (each data.values).createView()))
        }
    }
}

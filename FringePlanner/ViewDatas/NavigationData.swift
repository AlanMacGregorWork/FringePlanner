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
    let router: RouterType
    @FringeDataResultBuilder let values: (repeat each Content)
    
    struct NavigationView<each T: ViewDataProtocol>: View, ViewProtocol {
        private let data: NavigationData<RouterType, repeat each T>
        @ObservedObject private var router: RouterType
        @State private var path = NavigationPath()
        @State private var pushedSheet: RouterType.NavigationLocation?
        
        init(data: NavigationData<RouterType, repeat each T>) {
            self.data = data
            self._router = .init(initialValue: data.router)
        }
        
        var body: some View {
            NavigationStack(path: $path) {
                content
                    .navigationDestination(item: $pushedSheet,
                                           destination: { $0.toView() })
            }
            // Note: Theres an issue with directly using the `router.pushedSheet` for the `navigationDestination`
            // where a crash occurs, to get around this, a state value is used which can read and updated changes
            // to the router.
            .onChange(of: router.pushedSheet, { pushedSheet = router.pushedSheet })
            .onChange(of: pushedSheet, { router.pushedSheet = pushedSheet })
        }
        
        private var content: some View {
            TupleView((repeat (each data.values).createView()))
        }
    }
}

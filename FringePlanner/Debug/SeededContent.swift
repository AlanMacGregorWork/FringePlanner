//
//  SeededContent.swift
//  FringePlanner
//
//  Created by Alan MacGregor on 20/11/2024.
//

import Foundation

#if DEBUG

/// Allows basic example content to be used for debugging and testing uses. Not for production.
struct SeededContent {
    private static let allContent = AllContent()
    private let randomIntGenerator: PseudoRandomIntGenerator
    var randomNumber: Int { self.randomIntGenerator.get() }

    init(seed: Int = Int.random(in: 0...10000)) {
        self.randomIntGenerator = PseudoRandomIntGenerator(seed: seed)
    }
    
    struct AllContent {
        let postcodes = ["EH1 1QR", "EH2 2LR", "EH3 9QN", "EH6 4NP", "EH8 9AB", "EH10 4SD", "EH11 2JL", "EH15 2QR"]
        let phoneNumbers = ["0131 123 4567", "0131 234 5678", "0131 345 6789", "0131 456 7890", "0131 567 8901", "0131 678 9012", "0131 789 0123", "0131 890 1234", "0131 901 2345"]
        let eventDescriptions = [
            "A historic venue in the heart of Edinburgh. <br><br>Features include:<ul><li>Original Georgian architecture</li><li>Multiple performance spaces</li><li>Central location</li></ul>",
            "A modern arts space with multiple performance areas. <p>Recently renovated with state-of-the-art facilities.</p>",
            "An intimate theatre in a converted church. <strong>Perfect for dramatic performances</strong>.",
            "A vibrant cultural hub in the Old Town. <em>Home to some of the Fringe's most memorable shows</em>.",
            "A prestigious concert hall with <strong>excellent acoustics</strong> and rich history.",
            "A quirky underground venue with character. <br>Known for its <em>atmospheric performances</em>.",
            "A spacious multi-purpose performance space. <p>Hosting shows since 1947.</p>",
            "A traditional Scottish music venue. <ul><li>Live music daily</li><li>Traditional sessions</li></ul>",
            "A contemporary gallery and events space. <strong>Showcasing the best in modern performance art</strong>."
        ]
        let names = ["Assembly Rooms", "Pleasance Courtyard", "Summerhall", "The Stand Comedy Club", "Traverse Theatre", "Underbelly Cowgate", "Gilded Balloon Teviot", "The Queen's Hall", "Festival Theatre"]
        let addresses = ["54 George Street", "60 Pleasance", "1 Summerhall", "5 York Place", "10 Cambridge Street", "66 Cowgate", "13 Bristo Square", "85-89 Clerk Street", "13-29 Nicolson Street"]
        let webAddresses = ["https://www.assemblyfestival.com", "https://www.pleasance.co.uk", "https://www.summerhall.co.uk", "https://www.thestand.co.uk", "https://www.traverse.co.uk", "https://www.underbellyedinburgh.co.uk", "https://www.gildedballoon.co.uk", "https://www.thequeenshall.net", "https://www.capitaltheatres.com"]
        let emails = ["info@assemblyfestival.com", "info@pleasance.co.uk", "info@summerhall.co.uk", "info@thestand.co.uk", "info@traverse.co.uk", "info@underbelly.co.uk", "info@gildedballoon.co.uk", "info@thequeenshall.net", "info@capitaltheatres.com"]
        let disabledDescriptions = ["Wheelchair accessible, hearing loop available", "Level access, accessible toilets, lift to all floors", "Accessible entrance via ramp, adapted facilities", "Ground floor access, accessible toilets", "Full accessibility, BSL interpreted shows available", "Limited accessibility, please contact venue", "Lift access to all areas, accessible facilities", "Step-free access, accessible seating areas", "Full accessibility including wheelchair spaces"]
        let positions = [FringeVenue.Position(lat: 55.9533, lon: -3.1883), FringeVenue.Position(lat: 55.9478, lon: -3.1836), FringeVenue.Position(lat: 55.9419, lon: -3.1789), FringeVenue.Position(lat: 55.9557, lon: -3.1897), FringeVenue.Position(lat: 55.9468, lon: -3.2021), FringeVenue.Position(lat: 55.9486, lon: -3.1891), FringeVenue.Position(lat: 55.9465, lon: -3.1892), FringeVenue.Position(lat: 55.9412, lon: -3.1824), FringeVenue.Position(lat: 55.9467, lon: -3.1859)]
        let dates = (2...17).map({ DateComponents(calendar: .current, year: 2024, month: 8, day: $0, hour: 19, minute: 30).date! })
        let titles = ["The Stand-Up Sensation", "Shakespeare in Space", "Musical Mayhem", "Dance Through Time", "Comedy Chaos", "Magical Mysteries", "Poetry in Motion", "Circus Spectacular", "Late Night Laughs", "Drama in the Dark"]
        let artists = ["The Comedy Crew", "Theatre Company X", "Musical Mavericks", "Dance Collective", "Improv Troupe", "Magic Circle", "Poets United", "Circus Dreams", "Late Night Comics", "Drama Workshop"]
        let countries = ["United Kingdom", "Germany", "France", "Ireland", "Scotland", "Spain", "Italy", "Netherlands", "Belgium", "Denmark"]
        let teasers = ["A hilarious evening of non-stop laughter", "Classic theatre with a modern twist", "Musical entertainment for all ages", "Journey through dance history", "Improvised comedy at its finest", "Mind-bending illusions", "Words that move and inspire", "Acrobatic excellence", "Comedy after dark", "Dramatic masterpiece"]
        let codes = ["COM123", "THTR456", "MUS789", "DNC012", "IMP345", "MAG678", "POE901", "CIR234", "LNL567", "DRM890"]
        let ageCategories = ["16+", "12+", "All ages", "5+", "18+", "7+", "14+", "3+", "16+", "15+"]
        let venueDescriptions = [
            "Join us for an unforgettable evening of entertainment. <br><em>Book early to avoid disappointment!</em>",
            "A groundbreaking performance that <strong>pushes boundaries</strong>.",
            "Experience the magic of live performance. <p>Every show is unique.</p>",
            "Be transported to another world. <ul><li>Immersive staging</li><li>Professional cast</li></ul>",
            "Laugh until you cry. <br><strong>5-star reviews across the board!</strong>",
            "Prepare to be amazed. <em>Unlike anything you've seen before.</em>",
            "Feel the power of words. <p>Award-winning production.</p>",
            "Witness the impossible. <strong>Limited season only!</strong>",
            "Comedy that breaks all the rules. <br><em>Not for the faint-hearted.</em>",
            "Theatre that changes lives. <p>Critics' choice 2024.</p>"
        ]
        let festivals = ["Edinburgh Fringe", "Edinburgh International", "Edinburgh Jazz", "Edinburgh Art", "Edinburgh Film"]
        let festivalIds = ["EDF2024", "EIF2024", "EJF2024", "EAF2024", "EIFF2024"]
        let genres = ["Comedy", "Theatre", "Music", "Dance", "Magic", "Poetry", "Circus", "Cabaret", "Drama", "Physical Theatre"]
        let genreTags = ["Stand-up, Satire", "Drama, Classical", "Jazz, Contemporary", "Modern, Contemporary", "Magic, Family", "Spoken Word, Performance", "Acrobatics, Family", "Adult, Musical", "Tragedy, Contemporary", "Movement, Experimental"]
        let warnings = ["Strong language", "Strobe lighting", "Loud music", "Adult themes", "Smoke effects", "Contains nudity", "Violence", "Mature content", "Flashing lights", "Dark themes"]
        let ticketUrls = ["https://tickets.edfringe.com/COM123", "https://tickets.edfringe.com/THTR456", "https://tickets.edfringe.com/MUS789", "https://tickets.edfringe.com/DNC012", "https://tickets.edfringe.com/IMP345", "https://tickets.edfringe.com/MAG678", "https://tickets.edfringe.com/POE901", "https://tickets.edfringe.com/CIR234", "https://tickets.edfringe.com/LNL567", "https://tickets.edfringe.com/DRM890"]
        let websites = ["https://www.comedycrew.com", "https://www.theatrex.com", "https://www.musicmavericks.net", "https://www.dancecollective.org", "https://www.improvtroupe.co.uk", "https://www.magiccircle.com", "https://www.poetsunited.org", "https://www.circusdreams.com", "https://www.latenightcomics.com", "https://www.dramaworkshop.co.uk"]
        let disabledInfo = [
            FringeDisabled(otherServices: true, audio: true, captioningDates: ["2024-08-03", "2024-08-10"], signedDates: ["2024-08-05", "2024-08-12"]),
            FringeDisabled(otherServices: true, audio: false, captioningDates: ["2024-08-04", "2024-08-11"], signedDates: nil),
            FringeDisabled(otherServices: false, audio: true, captioningDates: nil, signedDates: ["2024-08-06", "2024-08-13"]),
            FringeDisabled(otherServices: false, audio: false, captioningDates: ["2024-08-07"], signedDates: ["2024-08-14"])
        ]
        let ageLimited = [nil, true, false]
    }

    private func seedValue<T>(for input: Int, at keyPath: KeyPath<AllContent, [T]>) -> T {
        let array = Self.allContent[keyPath: keyPath]
        let index = randomIntGenerator.get(maxNumber: array.count - 1)
        return array[index]
    }
    
    func venue(config: VenueSeedConfig? = nil) -> FringeVenue {
        let currentRandom = randomNumber
        let code = config?.code.value ?? String(currentRandom)
        return FringeVenue(
            code: code,
            description: seedValue(for: currentRandom, at: \.venueDescriptions),
            name: config?.name.value ?? seedValue(for: currentRandom, at: \.names),
            address: seedValue(for: currentRandom, at: \.addresses),
            position: seedValue(for: currentRandom, at: \.positions),
            postCode: seedValue(for: currentRandom, at: \.postcodes),
            webAddress: URL(string: seedValue(for: currentRandom, at: \.webAddresses)),
            phone: seedValue(for: currentRandom, at: \.phoneNumbers),
            email: seedValue(for: currentRandom, at: \.emails),
            disabledDescription: seedValue(for: currentRandom, at: \.disabledDescriptions)
        )
    }

    func date() -> Date {
        return seedValue(for: randomNumber, at: \.dates)
    }   
    
    func images() -> [String: FringeImage] {
        let version = FringeImage.Version(
            type: "original",
            width: 800,
            height: 600,
            mime: "image/jpeg",
            url: URL(string: "https://example.com/image.jpg")!
        )
        
        return ["someHash": FringeImage(hash: "someHash", orientation: .landscape, type: .thumb, versions: ["original": version])]
    }
    
    func performance(eventCode: String, config: PerformanceConfig? = nil) -> FringePerformance {
        let startDate = config?.start.value ?? date()
        let endDate = seedValue(for: randomNumber, at: \.dates).addingTimeInterval(60 * 60)
        let basePrice = Double((randomNumber % 4) + 1) * 10.00
        let concessionPrice = basePrice * 0.8
        let type = config?.type.value ?? .inPerson
        let title = config?.title.value ?? seedValue(for: randomNumber, at: \.titles)
        return FringePerformance(
            title: title,
            type: type,
            isAtFixedTime: true,
            priceType: basePrice == 0 ? .free : .paid,
            price: basePrice,
            concession: concessionPrice,
            priceString: basePrice == 0 ? "Free" : "£\(basePrice) (£\(concessionPrice) concessions)",
            start: startDate,
            end: endDate,
            durationMinutes: 60,
            eventCode: eventCode
        )
    }

    func event(config: EventSeedConfig? = nil) -> FringeEvent {
        let eventCode = config?.code.value ?? seedValue(for: randomNumber, at: \.codes)
        
        let venue = config?.venue.value.map({
            switch $0 {
            case .config(let config): self.venue(config: config)
            case .entireObject(let object): object
            }
        }) ?? self.venue()

        let performances = config?.performances.value ?? (1..<10).map({ _ in performance(eventCode: eventCode) })
        let ageLimited = seedValue(for: randomNumber, at: \.ageLimited)
        
        return .init(
            title: config?.title.value ?? seedValue(for: randomNumber, at: \.titles),
            artist: seedValue(for: randomNumber, at: \.artists),
            country: seedValue(for: randomNumber, at: \.countries),
            descriptionTeaser: seedValue(for: randomNumber, at: \.teasers),
            code: eventCode,
            ageCategory: seedValue(for: randomNumber, at: \.ageCategories),
            description: seedValue(for: randomNumber, at: \.eventDescriptions),
            festival: seedValue(for: randomNumber, at: \.festivals),
            festivalId: seedValue(for: randomNumber, at: \.festivalIds),
            genre: seedValue(for: randomNumber, at: \.genres),
            genreTags: seedValue(for: randomNumber, at: \.genreTags),
            performances: performances,
            performanceSpace: FringePerformanceSpace(name: "Main Hall", ageLimited: ageLimited),
            status: .active,
            url: URL(string: seedValue(for: randomNumber, at: \.ticketUrls))!,
            venue: venue,
            website: URL(string: seedValue(for: randomNumber, at: \.websites))!,
            disabled: seedValue(for: randomNumber, at: \.disabledInfo),
            images: images(),
            warnings: seedValue(for: randomNumber, at: \.warnings),
            updated: DateComponents(calendar: .current, year: 2024, month: 8, day: 1, hour: 19, minute: 30).date!,
            year: 2024
        )
    }
    
    func events(for config: [Int: EventSeedConfig] = [:]) -> [FringeEvent] {
        (1...25).map({ self.event(config: config[$0]) })
    }
}

extension Array where Element == FringeEvent {
    static func exampleModels() -> Self {
        SeededContent(seed: 8494536).events()
    }
}

// MARK: - Override Seed

extension SeededContent {
    
    // The following types allow the seed to be configured to override set values. For example, you may
    // need to test two different models but for them to use the same value for a `name` property
    
    struct VenueSeedConfig {
        let code: OverrideSeedValue<String>
        let name: OverrideSeedValue<String>
        
        init(
            code: OverrideSeedValue<String> = .doNotOverride,
            name: OverrideSeedValue<String> = .doNotOverride
        ) {
            self.code = code
            self.name = name
        }
    }
    
    struct PerformanceConfig {
        let title: OverrideSeedValue<String>
        let start: OverrideSeedValue<Date>
        let end: OverrideSeedValue<Date>
        let type: OverrideSeedValue<FringePerformanceType>
        
        init(
            title: OverrideSeedValue<String> = .doNotOverride,
            start: OverrideSeedValue<Date> = .doNotOverride,
            end: OverrideSeedValue<Date> = .doNotOverride,
            type: OverrideSeedValue<FringePerformanceType> = .doNotOverride
        ) {
            self.title = title
            self.start = start
            self.end = end
            self.type = type
        }
    }
    
    struct EventSeedConfig {
        let code: OverrideSeedValue<String>
        let title: OverrideSeedValue<String>
        let performances: OverrideSeedValue<[FringePerformance]>
        let venue: OverrideSeedValue<OverrideSeedVenueValue>
        
        init(
            code: OverrideSeedValue<String> = .doNotOverride,
            title: OverrideSeedValue<String> = .doNotOverride,
            performances: OverrideSeedValue<[FringePerformance]> = .doNotOverride,
            venue: OverrideSeedValue<OverrideSeedVenueValue> = .doNotOverride
        ) {
            self.code = code
            self.title = title
            self.performances = performances
            self.venue = venue
        }
    }

    /// Defines whether the seeding should be overridden with a specific value
    enum OverrideSeedValue<Value> {
        /// Allow default seeding to be used
        case doNotOverride
        /// Override the default seeding with a specific value
        case override(Value)
        
        /// Helper property to get the value if it is overridden
        var value: Value? {
            switch self {
            case .doNotOverride: return nil
            case .override(let value): return value
            }
        }
    }
    
    /// Helper enum to allow the venue to be overridden with an entire object or a configuration
    enum OverrideSeedVenueValue {
        /// Override the default seeding with a specific venue
        case entireObject(FringeVenue)
        /// Override the default seeding with a specific venue configuration
        case config(VenueSeedConfig)
    }
}

#endif

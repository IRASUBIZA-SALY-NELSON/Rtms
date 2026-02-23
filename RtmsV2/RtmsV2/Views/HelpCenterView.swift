import SwiftUI

struct HelpCenterView: View {
    @State private var searchText = ""
    
    let faqs = [
        FAQ(question: "How do I record a payment?", answer: "Go to the 'Pay' tab, select a class and student, then choose the direction and enter the amount. Tap 'Record Contribution' to finish.", category: "Payments"),
        FAQ(question: "Where can I see the history?", answer: "The 'Logs' tab contains a full audit trail of all recorded payments, including which user recorded them and when.", category: "Records"),
        FAQ(question: "How to change my password?", answer: "In your Profile, tap on 'Change Password'. You will need to enter your current password and a new strong one.", category: "Account"),
        FAQ(question: "Can I use RTMS on my phone?", answer: "Yes! RTMS is fully responsive and works beautifully on both iPhones and iPads.", category: "Technical")
    ]
    
    var filteredFaqs: [FAQ] {
        if searchText.isEmpty { return faqs }
        return faqs.filter { $0.question.localizedCaseInsensitiveContains(searchText) || $0.answer.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        ZStack {
            Color.rcaBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Search Bar
                    VStack(spacing: 16) {
                        Text("HOW CAN WE HELP YOU?")
                            .font(.system(size: 11, weight: .heavy))
                            .tracking(1)
                            .foregroundColor(.rcaSlate)
                        
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.rcaNavy)
                            TextField("Search help articles...", text: $searchText)
                                .font(.system(size: 14, weight: .bold))
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.04), radius: 5)
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    // Quick Links
                    HStack(spacing: 12) {
                        HelpCard(title: "Payments", icon: "creditcard.fill", color: .blue)
                        HelpCard(title: "Technical", icon: "gearshape.fill", color: .purple)
                        HelpCard(title: "Account", icon: "person.fill", color: .orange)
                    }
                    .padding(.horizontal)
                    
                    // FAQ List
                    VStack(alignment: .leading, spacing: 16) {
                        Text("FREQUENTLY ASKED QUESTIONS")
                            .font(.system(size: 11, weight: .heavy))
                            .tracking(1)
                            .foregroundColor(.rcaSlate)
                        
                        ForEach(filteredFaqs) { faq in
                            FAQRow(faq: faq)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 30)
            }
        }
        .navigationTitle("Help Center")
    }
}

struct FAQ: Identifiable {
    let id = UUID()
    let question: String
    let answer: String
    let category: String
}

struct FAQRow: View {
    let faq: FAQ
    @State private var isExpanded = false
    
    var body: some View {
        RCACard {
            VStack(alignment: .leading, spacing: 12) {
                Button(action: { withAnimation { isExpanded.toggle() } }) {
                    HStack {
                        Text(faq.question)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.rcaNavy)
                            .multilineTextAlignment(.leading)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.rcaSlate)
                            .rotationEffect(.degrees(isExpanded ? 180 : 0))
                    }
                }
                
                if isExpanded {
                    Text(faq.answer)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.rcaSlate)
                        .padding(.top, 4)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
    }
}

struct HelpCard: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(color)
                .cornerRadius(12)
            
            Text(title)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.rcaNavy)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 5)
    }
}

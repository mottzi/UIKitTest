import SwiftUI

struct GroupView: View
{
    var body: some View
    {
        ActivityPickerView()
            .ignoresSafeArea()
    }
}

struct ActivityPickerView: UIViewControllerRepresentable
{
    typealias UIViewControllerType = ActivityPicker
    
    func makeUIViewController(context: Context) -> ActivityPicker
    {
        return ActivityPicker()
    }
    
    func updateUIViewController(_ uiViewController: ActivityPicker, context: Context)
    {

    }
}

#Preview
{
    GroupView()
}

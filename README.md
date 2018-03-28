# MVPSimpleDemo
iOS MVP Simple Demo

[EN](#Requirements) | [中文](#中文说明)

## A dumb UI is a good UI: Using MVP in iOS

The Model-View-Controller is a common design pattern when it comes to the development of an iOS application. Usually the view layer consists of elements from UIKit defined programmatically or in xib-files, the model layer contains the business logic of the application and the controller layer, represented by classes of UIViewController, is the glue between model and view.

![](http://og1yl0w9z.bkt.clouddn.com/18-3-28/37046852.jpg)

One good part of this pattern is to have the business logic and business rules encapsulated in the model layer.However, the UIViewController still contains the UI related logic which means things like:

* calling the business logic and bind the results to the view
* managing the view elements
* transforming the data coming from the model layer into a UI friendly format
* navigation logic
* managing the UI state
* and more …

Having all of those responsibilities, ViewControllers often get huge and hard to maintain and to test.

So, it is time to think about improving MVC to deal with those problems. Let’s call this improvement Model-View-Presenter MVP.

The MVP pattern was first introduced in 1996 by Mike Potel and was discussed several times over the years. In his article GUI Architectures Martin Fowler discussed this pattern and compared it with other patterns for managing UI code.
There are many variations of MVP with small differences between them. In this post, i chose the common one that seems to be mostly used in the today’s app development. The characteristics of this variant are:

* the view part of the MVP consists of both UIViews and UIViewController
* the view delegates user interactions to the presenter
* the presenter contains the logic to handle user interactions
* the presenter communicates with model layer, converts the data to UI friendly format, and updates the view
* the presenter has no dependencies to UIKit
* the view is passiv (dump)

![](http://og1yl0w9z.bkt.clouddn.com/18-3-28/45649464.jpg)

The following example will show you how to use MVP in action.

Our example is a very simple application, that displays a simple user list. You can get the complete source code from hier: https://github.com/iyadagha/iOS-mvp-sample .

Let’s start with a simple data model for the user:

```Swift
struct User {
    let firstName: String
    let lastName: String
    let email: String
    let age: Int
}
```

Then we implement a simple UserService, that asynchronously returns a list of users:

```Swift
class UserService {
 
    //the service delivers mocked data with a delay
    func getUsers(callBack:([User]) -> Void){
        let users = [User(firstName: "Iyad", lastName: "Agha", email: "iyad@test.com", age: 36),
                     User(firstName: "Mila", lastName: "Haward", email: "mila@test.com", age: 24),
                     User(firstName: "Mark", lastName: "Astun", email: "mark@test.com", age: 39)
                    ]
 
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            callBack(users)
        }
    }
}
```

The next step ist writing the UserPresenter. First we need a data model of the user, that can be directly used from the view. It contains properly formatted data as needed from the view:

```Swift
struct UserViewData{   
    let name: String
    let age: String
}
```

After that, we need an abstraction of the view, which can be used in the presenter without knowing about UIViewController. We do that by defining a protocol UserView:

```Swift
protocol UserView: NSObjectProtocol {
    func startLoading()
    func finishLoading()
    func setUsers(users: [UserViewData])
    func setEmptyUsers()
}
```

This protocol will be used in the presenter and will be implemented later from the UIViewController. Basically, the protocol contains functions called in the presenter to control the view.

The presenter itself looks like:

```Swift
class UserPresenter {
    private let userService:UserService
    weak private var userView : UserView?
     
    init(userService:UserService){
        self.userService = userService
    }
     
    func attachView(view:UserView){
        userView = view
    }
     
    func detachView() {
        userView = nil
    }
     
    func getUsers(){
        self.userView?.startLoading()
        userService.getUsers{ [weak self] users in
            self?.userView?.finishLoading()
            if(users.count == 0){
                self?.userView?.setEmptyUsers()
            }else{
                let mappedUsers = users.map{
                    return UserViewData(name: "\($0.firstName) \($0.lastName)", age: "\($0.age) years")
                }
                self?.userView?.setUsers(mappedUsers)
            }
             
        }
    }
}
```

The presenter hat the functions attachView(view:UserView) and attachView(view:UserView) to have more control in the UIViewContoller’s life cycle method as we will see later.
Note that converting User to UserViewData is a responsibility of the presenter. Also note that userView must be weak to avoid retain cycle.

The last part of the implementation is the UserViewController:

```Swift
class UserViewController: UIViewController {
 
    @IBOutlet weak var emptyView: UIView?
    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView?
 
    private let userPresenter = UserPresenter(userService: UserService())
    private var usersToDisplay = [UserViewData]()
 
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView?.dataSource = self
        activityIndicator?.hidesWhenStopped = true
 
        userPresenter.attachView(self)
        userPresenter.getUsers()
    }
}
```

Our ViewController has a tableView to display the user list, an emptyView to display, if no users are available and an activityIndicator to display while the app is loading users. Furthermore, it has a userPresenter and a list of users.

In the viewDidLoad method, the UserViewController attach itself to the presenter. This works because the UserViewController, as we will see soon, implements the UserView protocol.

```Swift
extension UserViewController: UserView {
 
    func startLoading() {
        activityIndicator?.startAnimating()
    }
 
    func finishLoading() {
        activityIndicator?.stopAnimating()
    }
 
    func setUsers(users: [UserViewData]) {
        usersToDisplay = users
        tableView?.hidden = false
        emptyView?.hidden = true;
        tableView?.reloadData()
    }
 
    func setEmptyUsers() {
        tableView?.hidden = true
        emptyView?.hidden = false;
    }
}
```

As we see, these functions contains no complex logic, they are just doing pure view management.

Finally, the UITableViewDataSource implementation is very basic and looks like:


```Swift
extension UserViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usersToDisplay.count
    }
 
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "UserCell")
        let userViewData = usersToDisplay[indexPath.row]
        cell.textLabel?.text = userViewData.name
        cell.detailTextLabel?.text = userViewData.age
        cell.textLabel
        return cell
    }
}
```

![](http://og1yl0w9z.bkt.clouddn.com/18-3-28/45624241.jpg)

### Unit testing

One of the benefits of doing MVP is to be able to test the biggest part of the UI logic without testing the UIViewController itself. So if we have a good unit test coverage of our presenter, we don’t need to write unit tests for the UIViewController anymore.

Let’s now have a look on how we can test our UserPresenter. First we define tow mocks to work with. One mock is of the UserService to make it deliver the needed list of users. The other mock is of the UserView to verify if the methods are called properly.

```Swift
class UserServiceMock: UserService {
    private let users: [User]
    init(users: [User]) {
        self.users = users
    }
    override func getUsers(callBack: ([User]) -> Void) {
        callBack(users)
    }
 
}
 
class UserViewMock : NSObject, UserView{
    var setUsersCalled = false
    var setEmptyUsersCalled = false
 
    func setUsers(users: [UserViewData]) {
        setUsersCalled = true
    }
 
    func setEmptyUsers() {
        setEmptyUsersCalled = true
    }
}
```

Now, we can test if the presenter behave correctly when the service delivers a non empty list of users.

```Swift
class UserPresenterTest: XCTestCase {
 
    let emptyUsersServiceMock = UserServiceMock(users:[User]())
 
    let towUsersServiceMock = UserServiceMock(users:[User(firstName: "firstname1", lastName: "lastname1", email: "first@test.com", age: 30),
                                                     User(firstName: "firstname2", lastName: "lastname2", email: "second@test.com", age: 24)])
 
    func testShouldSetUsers() {
        //given
        let userViewMock = UserViewMock()
        let userPresenterUnderTest = UserPresenter(userService: towUsersServiceMock)
        userPresenterUnderTest.attachView(userViewMock)
 
        //when
        userPresenterUnderTest.getUsers()
 
        //verify
        XCTAssertTrue(userViewMock.setUsersCalled)
    }
}
```

In the same way we can test if the presenter works correctly if the service returns an empty list of users.

```Swift
func testShouldSetEmptyIfNoUserAvailable() {
        //given
        let userViewMock = UserViewMock()
        let userPresenterUnderTest = UserPresenter(userService: emptyUsersServiceMock)
        userPresenterUnderTest.attachView(userViewMock)
 
        //when
        userPresenterUnderTest.getUsers()
 
        //verify
        XCTAssertTrue(userViewMock.setEmptyUsersCalled)
    }
```

### Where to go from there

We have seen that MVP is an evolution of MVC. We only need to put the UI logic in an extra component called presenter and make our UIViewController passiv (dump).

One of the characteristics of MVP ist that both presenter and view know each other. The view, in this case the UIViewController, have a reference of the presenter and vice versa.
Though the reference of the view used in presenter could be removed using reactive programing. With reactive frameworks such as ReactiveCocoa or RxSwift it is possible to build an architecture, where only the view knows about the presenter and not vice versa. In this case the architecture would be called MVVM.

#### Article Source

Iyad Agha's Blog：http://iyadagha.com/using-mvp-ios-swift/

---
# 中文说明

## 用一个简单的用户界面展示：在iOS中用使用 MVP

在开发iOS应用程序时，Model-View-Controller是一种常见的设计模式。 通常，视图层由UIKit中的元素组成，这些元素由编程定义或xib文件定义，模型层包含应用程序的业务逻辑，并且由UIViewController类表示的控制器层是模型和视图之间的粘合剂。

![](http://og1yl0w9z.bkt.clouddn.com/18-3-28/37046852.jpg)

这种模式的一个很好的部分是将业务逻辑和业务规则封装在模型层中。但是，UIViewController仍然包含UI相关的逻辑，它的意思是：

*调用业务逻辑并将结果绑定到视图
*管理视图元素
*将来自模型层的数据转换为UI友好的格式
*导航逻辑
*管理用户界面状态
* 和更多 …

承担所有这些责任，ViewController经常会变得巨大且难以维护并进行测试。

所以，现在是时候考虑改进MVC来处理这些问题了。我们称之为Model-View-Presenter MVP的改进。

MVP模式在1996年由Mike Potel首次引入，多年来曾多次讨论过。在他的文章GUI架构中，Martin Fowler讨论了这种模式，并将其与用于管理UI代码的其他模式进行了比较。
MVP有许多变体，它们之间的差别很小。在这篇文章中，我选择了目前应用程序开发中常用的常用程序。这个变体的特点是：

* MVP的视图部分由UIViews和UIViewController组成
*视图委托给演示者的用户交互
*演示者包含处理用户交互的逻辑
*演示者与模型层进行通信，将数据转换为UI友好的格式，并更新视图
*演示者对UIKit没有依赖性
*视图是passiv（转储）

![](http://og1yl0w9z.bkt.clouddn.com/18-3-28/45649464.jpg)

以下示例将向您展示如何在操作中使用MVP。

我们的例子是一个非常简单的应用程序，显示一个简单的用户列表。 你可以从hier获得完整的源代码：https：//github.com/iyadagha/iOS-mvp-sample。

让我们从用户的简单数据模型开始：

```Swift
struct User {
    let firstName: String
    let lastName: String
    let email: String
    let age: Int
}
```

然后我们实现一个简单的UserService，它异步返回一个用户列表：

```Swift
class UserService {
 
    //the service delivers mocked data with a delay
    func getUsers(callBack:([User]) -> Void){
        let users = [User(firstName: "Iyad", lastName: "Agha", email: "iyad@test.com", age: 36),
                     User(firstName: "Mila", lastName: "Haward", email: "mila@test.com", age: 24),
                     User(firstName: "Mark", lastName: "Astun", email: "mark@test.com", age: 39)
                    ]
 
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            callBack(users)
        }
    }
}
```

下一步是编写UserPresenter。 首先我们需要用户的数据模型，可以直接从视图中使用。 它包含根据需要从视图中正确格式化的数据：

```Swift
struct UserViewData{   
    let name: String
    let age: String
}
```

之后，我们需要对视图进行抽象，这可以在演示者不知道UIViewController的情况下使用。 我们通过定义一个协议UserView来做到这一点：

```Swift
protocol UserView: NSObjectProtocol {
    func startLoading()
    func finishLoading()
    func setUsers(users: [UserViewData])
    func setEmptyUsers()
}
```

该协议将在演示者中使用，稍后将从UIViewController实现。 基本上，协议包含在演示者中调用的用于控制视图的函数。

用户本身看起来像：

```Swift
class UserPresenter {
    private let userService:UserService
    weak private var userView : UserView?
     
    init(userService:UserService){
        self.userService = userService
    }
     
    func attachView(view:UserView){
        userView = view
    }
     
    func detachView() {
        userView = nil
    }
     
    func getUsers(){
        self.userView?.startLoading()
        userService.getUsers{ [weak self] users in
            self?.userView?.finishLoading()
            if(users.count == 0){
                self?.userView?.setEmptyUsers()
            }else{
                let mappedUsers = users.map{
                    return UserViewData(name: "\($0.firstName) \($0.lastName)", age: "\($0.age) years")
                }
                self?.userView?.setUsers(mappedUsers)
            }
             
        }
    }
}
```

主持人将函数attachView（view：UserView）和attachView（view：UserView）用于UIViewContoller生命周期方法中的更多控制，我们将在后面看到。
请注意，将用户转换为UserViewData是演示者的责任。 另请注意，userView必须很弱以避免保留周期。

实现的最后一部分是UserViewController：

```Swift
class UserViewController: UIViewController {
 
    @IBOutlet weak var emptyView: UIView?
    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView?
 
    private let userPresenter = UserPresenter(userService: UserService())
    private var usersToDisplay = [UserViewData]()
 
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView?.dataSource = self
        activityIndicator?.hidesWhenStopped = true
 
        userPresenter.attachView(self)
        userPresenter.getUsers()
    }
}
```

我们的ViewController有一个tableView来显示用户列表，一个emptyView显示，如果没有用户可用，一个activityIndicator在应用程序加载用户时显示。 此外，它还有一个userPresenter和一个用户列表。

在viewDidLoad方法中，UserViewController将自己附加到演示者。 这是可行的，因为我们很快会看到UserViewController实现了UserView协议。

```Swift
extension UserViewController: UserView {
 
    func startLoading() {
        activityIndicator?.startAnimating()
    }
 
    func finishLoading() {
        activityIndicator?.stopAnimating()
    }
 
    func setUsers(users: [UserViewData]) {
        usersToDisplay = users
        tableView?.hidden = false
        emptyView?.hidden = true;
        tableView?.reloadData()
    }
 
    func setEmptyUsers() {
        tableView?.hidden = true
        emptyView?.hidden = false;
    }
}
```

正如我们所看到的，这些功能不包含复杂的逻辑，他们只是在进行纯视图管理。

最后，UITableViewDataSource实现非常基本，如下所示：


```Swift
extension UserViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usersToDisplay.count
    }
 
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "UserCell")
        let userViewData = usersToDisplay[indexPath.row]
        cell.textLabel?.text = userViewData.name
        cell.detailTextLabel?.text = userViewData.age
        cell.textLabel
        return cell
    }
}
```

![](http://og1yl0w9z.bkt.clouddn.com/18-3-28/45624241.jpg)

### 单元测试

做MVP的好处之一是能够测试UI逻辑的最大部分，而无需测试UIViewController本身。 所以如果我们的主持人有一个很好的单元测试覆盖率，我们不需要再为UIViewController编写单元测试。

现在让我们来看看我们如何测试UserPresenter。 首先我们定义两个模拟工作。 一个模拟是UserService使它提供所需的用户列表。 另一个模拟是UserView来验证方法是否被正确调用。

```Swift
class UserServiceMock: UserService {
    private let users: [User]
    init(users: [User]) {
        self.users = users
    }
    override func getUsers(callBack: ([User]) -> Void) {
        callBack(users)
    }
 
}
 
class UserViewMock : NSObject, UserView{
    var setUsersCalled = false
    var setEmptyUsersCalled = false
 
    func setUsers(users: [UserViewData]) {
        setUsersCalled = true
    }
 
    func setEmptyUsers() {
        setEmptyUsersCalled = true
    }
}
```

现在，我们可以测试当服务提供非空的用户列表时，演示者的行为是否正确。

```Swift
class UserPresenterTest: XCTestCase {
 
    let emptyUsersServiceMock = UserServiceMock(users:[User]())
 
    let towUsersServiceMock = UserServiceMock(users:[User(firstName: "firstname1", lastName: "lastname1", email: "first@test.com", age: 30),
                                                     User(firstName: "firstname2", lastName: "lastname2", email: "second@test.com", age: 24)])
 
    func testShouldSetUsers() {
        //given
        let userViewMock = UserViewMock()
        let userPresenterUnderTest = UserPresenter(userService: towUsersServiceMock)
        userPresenterUnderTest.attachView(userViewMock)
 
        //when
        userPresenterUnderTest.getUsers()
 
        //verify
        XCTAssertTrue(userViewMock.setUsersCalled)
    }
}
```

同样，如果服务返回空的用户列表，我们可以测试演示者是否正常工作。

```Swift
func testShouldSetEmptyIfNoUserAvailable() {
        //given
        let userViewMock = UserViewMock()
        let userPresenterUnderTest = UserPresenter(userService: emptyUsersServiceMock)
        userPresenterUnderTest.attachView(userViewMock)
 
        //when
        userPresenterUnderTest.getUsers()
 
        //verify
        XCTAssertTrue(userViewMock.setEmptyUsersCalled)
    }
```

### 去哪里去

我们已经看到MVP是MVC的演变。 我们只需要将UI逻辑放在一个名为Presenter的额外组件中，并使我们的UIViewController passiv（dump）成为可能。

MVP的特点之一是，主持人和观点都相互认识。 该视图（在本例中为UIViewController）提供了演示者的引用，反之亦然。
尽管可以使用反应式编程来删除演示者中使用的视图的参考。 通过使用ReactiveCocoa或RxSwift等响应式框架，可以构建一个体系结构，其中只有视图知道演示者，反之亦然。 在这种情况下，该架构将被称为MVVM。

#### 文章来源

Iyad Agha 的博客：http://iyadagha.com/using-mvp-ios-swift/

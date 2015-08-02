# NWLayoutInflator

A project that lets you create UIView subclasses with XML. If you have a file named testLayout.xml:

```xml
<LayoutView>
<UILabel text="Hello World!" id="label" x="20" y="50" sizeToFit="1" backgroundColor="#FFE0A0" />
<UIButton id="clickme" onclick="moveFrame" text="Click Me" textColor="white" cornerRadius="5" below="label" alignLeft="label" sizeToFit="1" backgroundColor="#40FF0000" marginTop="5" borderColor="black" borderWidth="1" />
<UILabel id="ontheright" text="on the right" sizeToFit="1" textColor="#D030A0" toRightOf="clickme" alignTop="clickme" marginLeft="10" />
<UIImageView id="image" below="ontheright" alignLeft="ontheright" width="50" height="50" imageNamed="camera_button_blue" />
</LayoutView>
```

![Screen shot of example xml](https://github.com/nickwah/NWLayoutInflator/testLayoutExample.png)

In your viewcontroller you can inflate this into a UIView hierarchy:

```objective-c
@implementation ViewController {
  NWLayoutView *_layoutView;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib.
  _layoutView = [[NWLayoutView alloc] initWithLayout:@"testLayout" andFrame:self.view.bounds andDelegate:self];
  [self.view addSubview:_layoutView];
}

- (void)moveFrame {
  _layoutView.frame = CGRectMake(120, 20, 200, 200);
}
```

You can also grab a specific view from the hierarchy by the id: `(UIButton*)[_layoutView findViewById:@"clickme"]`


//
//  ContactListTableViewController.h
//  Phone
//
//  Created by angel li on 10-9-13.
//
//

#import <UIKit/UIKit.h>
#import "ABContact.h"
#import "ContactDB.h"

@interface ContactListTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource,
                                                        UISearchBarDelegate,
                                                        ContactDBObserver> {

}


@end

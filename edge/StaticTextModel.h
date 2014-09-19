//
//  StaticTextModel.h
//  edge
//
//  Created by Ryan G Walton on 9/11/13.
//  Copyright (c) 2013 unknown. All rights reserved.
//

#import <Foundation/Foundation.h>
/*
Need for intranet privacy statement (Mary) ALL INFORMATION COLLECTED WILL BE GOVERNED BY OUR PRIVACY POLICY.
Need to create and link to internal privacy policy (Mary) MARY TO PROVIDE	
 */

#define INTRANET_PRIVACY_STATEMENT @"ALL INFORMATION COLLECTED WILL BE GOVERNED BY OUR PRIVACY POLICY."
#define INTERNAL_PRIVACY_POLICY @"MARY TO PROVIDE"

#define EMAIL_PRIVACY_STATEMENT @"This email transmission may contain confidential or legally privileged information that is intended only for the individual or entity named in the email address.  If you are not the intended recipient, you are hereby notified that any disclosure, copying, distribution, or reliance upon the contents of this email is strictly prohibited.  If you have received this email transmission in error, please reply to the sender, so that J&J can arrange for proper delivery, and then please delete the message from your inbox."


@interface StaticTextModel : NSObject

+ (StaticTextModel*) sharedInstance;

-(NSString *) privacyPolicyText;

@end

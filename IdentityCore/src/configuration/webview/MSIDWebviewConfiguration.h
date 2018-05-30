//------------------------------------------------------------------------------
//
// Copyright (c) Microsoft Corporation.
// All rights reserved.
//
// This code is licensed under the MIT License.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files(the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and / or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions :
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
//------------------------------------------------------------------------------

#import <Foundation/Foundation.h>
#import "MSIDConfiguration.h"

@class MSIDPkce;
@class MSIDClientInfo;

@interface MSIDWebviewConfiguration : MSIDConfiguration

// Common
@property (readwrite) NSURL *authorizationEndpoint;

@property (readwrite) NSDictionary<NSString *, NSString *> *extraQueryParameters;
@property (readwrite) NSString *promptBehavior;
@property (readwrite) NSString *claims;
@property (readwrite) NSDictionary<NSString *, NSString *> *customHeaders;

// Is this only for V2?
@property (readwrite) MSIDPkce *pkce;

// User information
@property (readwrite) NSString *utid;
@property (readwrite) NSString *uid;

// Priority start URL
@property (readwrite) NSURL *explicitStartURL;

#if TARGET_OS_IPHONE
@property (weak) UIViewController *parentController;
@property (readwrite)UIModalPresentationStyle presentationType;
#endif

- (instancetype)initWithAuthority:(NSURL *)authority
            authorizationEndpoint:(NSURL *)authorizationEndpoint
                      redirectUri:(NSString *)redirectUri
                         clientId:(NSString *)clientId
                           target:(NSString *)target
                    correlationId:(NSUUID *)correlationId;

- (instancetype)initWithAuthority:(NSURL *)authority redirectUri:(NSString *)redirectUri clientId:(NSString *)clientId target:(NSString *)target correlationId:(NSUUID *)correlationId NS_UNAVAILABLE;
- (instancetype)initWithAuthority:(NSURL *)authority redirectUri:(NSString *)redirectUri clientId:(NSString *)clientId target:(NSString *)target NS_UNAVAILABLE;

@end

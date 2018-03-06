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
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "MSIDAADTokenResponse.h"
#import "MSIDTelemetryEventStrings.h"
#import "MSIDAADV1IdTokenWrapper.h"

@interface MSIDAADTokenResponse ()

@property (readonly) NSString *rawClientInfo;

@end

@implementation MSIDAADTokenResponse

// Default properties for an error response
MSID_JSON_ACCESSOR(MSID_OAUTH2_CORRELATION_ID_RESPONSE, correlationId)

// Default properties for a successful response
MSID_JSON_ACCESSOR(MSID_OAUTH2_EXPIRES_ON, expiresOn);
MSID_JSON_ACCESSOR(MSID_OAUTH2_EXT_EXPIRES_IN, extendedExpiresIn)
MSID_JSON_ACCESSOR(MSID_OAUTH2_RESOURCE, resource)
MSID_JSON_ACCESSOR(MSID_OAUTH2_CLIENT_INFO, rawClientInfo)
MSID_JSON_ACCESSOR(MSID_FAMILY_ID, familyId)
MSID_JSON_ACCESSOR(MSID_TELEMETRY_KEY_SPE_INFO, speInfo)

- (id)initWithJSONDictionary:(NSDictionary *)json error:(NSError *__autoreleasing *)error
{
    if (!(self = [super initWithJSONDictionary:json error:error]))
    {
        return nil;
    }
    
    if (self.extendedExpiresIn
        && [self.extendedExpiresIn respondsToSelector:@selector(doubleValue)])
    {
        _extendedExpiresOnDate = [NSDate dateWithTimeIntervalSinceNow:[self.extendedExpiresIn integerValue]];
    }
    
    if (self.rawClientInfo)
    {
        _clientInfo = [[MSIDClientInfo alloc] initWithRawClientInfo:self.rawClientInfo error:nil];
    }
    
    return self;
}

- (NSDate *)expiryDate
{
    NSDate *date = [super expiryDate];
    
    if (date)
    {
        return date;
    }
    
    NSString *expiresOn = self.expiresOn;
    
    if (!expiresOn)
    {
        if (_json[MSID_OAUTH2_EXPIRES_ON])
        {
            MSID_LOG_WARN(nil, @"Unparsable time - The response value for the access token expiration cannot be parsed: %@", _json[MSID_OAUTH2_EXPIRES_ON]);
        }
        
        return nil;
    }
    
    return [NSDate dateWithTimeIntervalSince1970:[expiresOn integerValue]];
}

- (BOOL)verifyExtendedProperties:(id<MSIDRequestContext>)context
                           error:(NSError **)error
{
    [self checkCorrelationId:context.correlationId];
    
    if (!self.clientInfo)
    {
        MSID_LOG_ERROR(context, @"Client info was not returned in the server response");
        MSID_LOG_ERROR_PII(context, @"Client info was not returned in the server response");
        if (error)
        {
            *error = MSIDCreateError(MSIDErrorDomain, MSIDErrorInternal, @"Client info was not returned in the server response", nil, nil, nil, context.correlationId, nil);
        }
        return NO;
    }
    
    return YES;
}

- (void)checkCorrelationId:(NSUUID *)requestCorrelationId
{
    MSID_LOG_VERBOSE_CORR(requestCorrelationId, @"Token extraction. Attempt to extract the data from the server response.");
    
    if (![NSString msidIsStringNilOrBlank:self.correlationId])
    {
        NSUUID *responseUUID = [[NSUUID alloc] initWithUUIDString:self.correlationId];
        if (!responseUUID)
        {
            MSID_LOG_INFO_CORR(requestCorrelationId, @"Bad correlation id - The received correlation id is not a valid UUID. Sent: %@; Received: %@", requestCorrelationId, self.correlationId);
        }
        else if (![requestCorrelationId isEqual:responseUUID])
        {
            MSID_LOG_INFO_CORR(requestCorrelationId, @"Correlation id mismatch - Mismatch between the sent correlation id and the received one. Sent: %@; Received: %@", requestCorrelationId, self.correlationId);
        }
    }
    else
    {
        MSID_LOG_INFO_CORR(requestCorrelationId, @"Missing correlation id - No correlation id received for request with correlation id: %@", [requestCorrelationId UUIDString]);
    }
}

@end
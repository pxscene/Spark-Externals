/*
 * If not stated otherwise in this file or this component's license file the
 * following copyright and licenses apply:
 *
 * Copyright 2018 RDK Management
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
*/


/**
* @file AampDRMutils.h
* @brief Data structures to help with DRM sessions. 
*/

#ifndef AampDRMutils_h
#define AampDRMutils_h

#include <stdio.h>
#include <assert.h>
#include <stdlib.h>
#include <string.h>

/**
 * @class DrmData
 * @brief To hold DRM key, license request etc.
 */
class DrmData{

private:
	unsigned char *data;
	int dataLength;
public:

	DrmData();
	DrmData(unsigned char *data, int dataLength);
	DrmData(const DrmData&) = delete;
	DrmData& operator=(const DrmData&) = delete;
	~DrmData();

	unsigned char * getData();

	int getDataLength();

	void setData(unsigned char * data, int dataLength);

	void addData(unsigned char * data, int dataLength);

};

#endif

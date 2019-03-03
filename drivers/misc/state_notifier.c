/*
 * Suspend state tracker driver
 *
 * Copyright (c) 2013-2017, Pranav Vashi <neobuddy89@gmail.com>
 *           (c) 2017, Joe Maples <joe@frap129.org>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 as
 * published by the Free Software Foundation.
 *
 */

#include <linux/export.h>
#include <linux/module.h>
#include <linux/msm_drm_notify.h>

bool state_suspended;

static int msm_drm_notifier_cb(struct notifier_block *nb,
			       unsigned long action, void *data)
{
	struct msm_drm_notifier *evdata = data;
	int *blank = evdata->data;

	/* Parse framebuffer blank events as soon as they occur */
	if (action != MSM_DRM_EARLY_EVENT_BLANK)
		return NOTIFY_OK;

	state_suspended = *blank == MSM_DRM_BLANK_UNBLANK;

	return NOTIFY_OK;
}

static struct notifier_block display_state_nb __ro_after_init = {
	.notifier_call = msm_drm_notifier_cb,
};

static int __init state_notifier_init(void)
{
	int ret;

	ret = msm_drm_register_client(&display_state_nb);
	if (ret)
		pr_err("Failed to register msm_drm notifier, err: %d\n", ret);

	return ret;
}
late_initcall(state_notifier_init);

MODULE_AUTHOR("Pranav Vashi <neobuddy89@gmail.com>");
MODULE_DESCRIPTION("Suspend state tracker");
MODULE_LICENSE("GPLv2");

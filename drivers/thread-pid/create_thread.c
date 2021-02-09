#include <linux/module.h>
#include <linux/init.h>
#include <asm/sysreg.h>
#include <linux/sched/task.h>

/*pid_t kernel_thread(int (*fn)(void *), void *arg, unsigned long flags)*/

int kthread_fn(void *unsed)
{
	printk(KERN_ERR "tom F=%s L=%d current->pid=%d\n",__func__,__LINE__,current->pid);
	return 0;
}
static int __init thread_pid_init(void)
{
	int pid;
	pid = kernel_thread(kthread_fn,NULL , CLONE_FS | CLONE_FILES);
	printk(KERN_ERR "tom F=%s pid=%d\n",__func__,pid);
	return 0;
}

static void __exit thread_pid_exit(void)
{
	printk("tom thread_pid_exit\n");
}

module_init(thread_pid_init);
module_exit(thread_pid_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("tom");
MODULE_DESCRIPTION("my test kernel module");
MODULE_ALIAS("mytest");

